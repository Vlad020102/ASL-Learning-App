import {
  Injectable,
  ConflictException,
  NotFoundException,
  HttpException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CreateUserDto } from './dto/create-user.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { QuizStatus, QuizType, User } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) { }

  async findOne(id: number) {
    return await this.prisma.user.findUnique({
      where: { id },
    });
  }

  async create(userData: CreateUserDto) {
    const existingUser = await this.findByUsername(userData.username);
    if (existingUser) {
      throw new ConflictException('Username already exists');
    }

    const hashedPassword = await bcrypt.hash(userData.password, 10);

    return await this.prisma.user.create({
      data: {
        ...userData,
        password: hashedPassword,
      },
    });
  }

  async findAll() {
    return await this.prisma.user.findMany();
  }

  async findByUsername(username: string) {
    if (username === '') return null;
    return await this.prisma.user.findUnique({
      where: { username },
    });
  }

  async findByEmail(email: string) {
    if (email === '') return null;
    return await this.prisma.user.findUnique({
      where: { email },
    });
  }

  async findProfile(user: User) {
    const userWithBadges = await this.prisma.user.findUnique({
      where: { username: user.username },
      include: {
        badges: {
          select: {
            id: true,
            progress: true,
            status: true,
            badge: {
              select: {
                name: true,
                description: true,
                icon: true,
                type: true,
                rarity: true,
                target: true,
              },
            },
          }
        },
      },
    });

    const userProfile = userWithBadges ? {
      ...userWithBadges,
      badges: userWithBadges.badges.map(badge => ({
        id: badge.id,
        progress: badge.progress,
        status: badge.status,
        ...badge.badge,
      })),
    } : null;
    if (!userProfile) {
      throw new NotFoundException('User not found');
    }

    const { id, password, ...profileWithoutId } = userProfile;
    return profileWithoutId;
  }

  async getUserBadges(user: User) {
    const userBadges = await this.prisma.userBadge.findMany({
      where: {
        user: {
          username: user.username,
        }
      },
    });
    const badges = await this.prisma.badge.findMany({})
    const filteredBadges = badges.filter((badge) => {
      return !userBadges.some((userBadge) => userBadge.badgeID === badge.id);
    });
    for (const badge of filteredBadges) {
      await this.prisma.userBadge.create({
        data: {
          user: {
            connect: {
              username: user.username,
            },
          },
          badge: {
            connect: {
              id: badge.id,
            },
          }
        },
      });
    }

  }

  async getStreaks(user: User) {
    const quizUserAnsweredDates = await this.prisma.quizUser.findMany({
      where: {
        userID: user.id,
        status: QuizStatus.Completed,
      },
      select: {
        answeredAt: true,
        user: {
          select: {
            streak: true,
          }
        }
      },

    });

    // Initialize calendar object
    const calendar = {
      january: [],
      february: [],
      march: [],
      april: [],
      may: [],
      june: [],
      july: [],
      august: [],
      september: [],
      october: [],
      november: [],
      december: []
    };


    // Group dates by month
    quizUserAnsweredDates.forEach(({ answeredAt }) => {
      if (answeredAt) {
        const month = answeredAt.toLocaleString('en-US', { month: 'long' }).toLowerCase();
        const day = answeredAt.getDate();

        if (!calendar[month].includes(day)) {
          calendar[month].push(day);
        }
      }
    });

    Object.keys(calendar).forEach(month => {
      calendar[month].sort((a, b) => a - b);
    });

    return {
      "currentStreak": quizUserAnsweredDates[0]?.user.streak ?? 0,
      "calendar": calendar,
    }
  }

  async updateUserLevel(user: User, score: number, livesRemaining: number, quizId: number) {
    const quiz = await this.prisma.quiz.findUnique({
      where: {
        id: quizId,
      },
      select: {
        type: true,
        title: true,
      }
    });
    if (!quiz) {
      throw new NotFoundException('Quiz not found');
    }

    const quizDifficulty = quiz.title.includes("Basic") ? 1 : quiz.title.includes("Advanced") ? 2 : 3;
    const amount = await this.computeLevelAmount(score, livesRemaining, quiz.type, quizDifficulty)
    const updatedUser = await this.prisma.user.update({
      where: {
        id: user.id,
      },
      data: {
        level_progress: {
          increment: amount,
        }
      },
      select: {
        level: true,
        level_progress: true,
      }
    });

    return await this.prisma.user.update({
      where: {
        id: user.id,
      },
      data: {
        level: updatedUser.level_progress / 10
      }
    });
  }

  async updateUserQuestionsAnswered(user: User) {
    return await this.prisma.user.update({
      where: {
        id: user.id,
      },
      data: {
        questionsAnsweredTotal: {
          increment: 5,
        }
      }
    });
  }

  private async computeLevelAmount(score: number, livesRemaining: number, quizType: QuizType, quizDifficulty: number) {
    let amount = 0;
    if (quizType === QuizType.Bubbles) {
      amount = Math.floor(score * (livesRemaining + 1) * quizDifficulty);
    } else if (quizType === QuizType.Matching) {
      amount = Math.floor(score * (livesRemaining + 1) * quizDifficulty)
    }    
    return amount;
  }
}

