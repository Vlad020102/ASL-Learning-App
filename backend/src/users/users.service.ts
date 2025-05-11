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
import { Cache } from 'cache-manager';
import { Inject } from '@nestjs/common';

@Injectable()
export class UsersService {
  constructor(
  private readonly prisma: PrismaService,
  @Inject('CACHE_MANAGER') private cacheManager: Cache
) { }

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
    const referralCode = `${userData.username}-${Math.floor(Math.random() * 10000)}`;

    const user = await this.prisma.user.create({
      data: {
        ...userData,
        password: hashedPassword,
        referralCode: referralCode,
      },
    });

    if (userData.referralCode) {
      const refferedUser = await this.prisma.user.findUnique({
        where: {
          referralCode: userData.referralCode,
        },
      });

      if (!refferedUser) {
        throw new NotFoundException('Referral code not found');
      }
      await this.createReferralCode(refferedUser.id, user.id, userData.referralCode);
      await this.addMoney(refferedUser.id, 100);
      await this.addMoney(user.id, 100);
      user.money += 100;
    }
    return user;
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
    const userWithBadgesAndFreezes = await this.prisma.user.findUnique({
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
        streakFreezes: { // Add this include
          select: {
            id: true,
            date: true,
          },
        },
      },
    });

    const userProfile = userWithBadgesAndFreezes ? {
      ...userWithBadgesAndFreezes, // money is already part of user model, streakFreezes is now included
      badges: userWithBadgesAndFreezes.badges.map(badge => ({
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

  async buyStreakFreeze(user: User, price: number) {
    
    const userWithStreak = await this.prisma.user.findUnique({
      where: {
        username: user.username,
      },
      select: {
        id: true,
        money: true,
        streak: true,
        streakFreezes: {
          select: {
            id: true,
            date: true,
          }
        }
      }
    });
    
    if (!userWithStreak) {
      throw new NotFoundException('User not found');
    }
    
    this.cacheManager.mdel(['/users/profile', 'users/streaks']); // Corrected mdel to del

    if(userWithStreak.money < price) {
      throw new HttpException('Not enough money', 400);
    }

    // Check if the user already has a streak freeze for today
    const today = new Date();
    const streakFreezeExists = userWithStreak.streakFreezes.some(streakFreeze => {
      const streakFreezeDate = new Date(streakFreeze.date);
      return (
        streakFreezeDate.getFullYear() === today.getFullYear() &&
        streakFreezeDate.getMonth() === today.getMonth() &&
        streakFreezeDate.getDate() === today.getDate()
      );
    });

    if (streakFreezeExists) {
      throw new HttpException('You already have a streak freeze for today', 400);
    }
    
    // Deduct the price from the user's money
    const updatedUser = await this.prisma.user.update({
      where: {
        username: user.username,
      },
      data: {
        money: {
          decrement: price,
        },
        streakFreezes: {
          create: {
            date: new Date(),
          }
        }
      },
      include: { // Include streakFreezes to return the updated list
        streakFreezes: {
          select: {
            id: true,
            date: true,
          }
        }
      }
    });
    
    return updatedUser.streakFreezes;
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

  async createReferralCode(userId: number, receiverID: number, referralCode: string) {
    const existingReferral = await this.prisma.referral.findUnique({
      where: {
        receiverID: receiverID,
      },
    });

    if (existingReferral) {
      throw new ConflictException('Referral code already exists');
    }

    return this.prisma.referral.create({
      data: {
        referralCode: referralCode,
        owner: {
          connect: {
            id: userId,
          },
        },
        receiver: {
          connect: {
            id: receiverID,
          }
        }
      },
    });
  }

  async addMoney(userId: number, amount: number) {
    return this.prisma.user.update({
      where: { id: userId },
      data: {
        money: {
          increment: amount,
        },
      },
    });
  }
}

