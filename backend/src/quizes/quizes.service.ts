import { HttpException, Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { QuizStatus, QuizType, User } from '@prisma/client';
import { CompleteQuizDTO } from './entities/completeQuiz';

@Injectable()
export class QuizesService {
  constructor(private readonly prisma: PrismaService) { }
  async populateQuiz(user: User) {
    const userQuizes = await this.prisma.quizUser.findMany({
      where: {
        user: {
          username: user.username
        }
      },
    });

    const quizes = await this.prisma.quiz.findMany({})
    const filteredQuizes = quizes.filter((quiz) => {
      return !userQuizes.some((userQuiz) => userQuiz.quizID === quiz.id);
    });
    for (const quiz of filteredQuizes) {
      await this.prisma.quizUser.create({
        data: {
          quiz: {
            connect: {
              id: quiz.id
            }
          },
          user: {
            connect: {
              username: user.username
            }
          },
        }
      })
    }
}

  async findAllQuizesForUser(user: User) {
    const userQuizes = await this.prisma.user.findUnique({
      where: { username: user.username },
      include: {
        quizzes: {
          select: {
            status: true,
            livesRemaining: true,
            score: true,
            quiz: {
              select: {
                id: true,
                title: true,
                type: true,
                signs: {
                  select: {
                    sign: true,
                    options: true,
                  }
                },
                pairs: {
                  select: {
                    matchIndex: true,
                    pair: {
                      select: {
                        id: true,
                        text: true,
                        signGif: true,
                      }
                    }
                  }
                }
              },
            },
          }
        },
      },
    });
    return {
      "quizes": {
        "bubblesQuizes": userQuizes?.quizzes.filter((quiz) => quiz.quiz.type === QuizType.Bubbles).map((quiz) => {
          return {
            id: quiz.quiz.id,
            title: quiz.quiz.title,
            type: quiz.quiz.type,
            status: quiz.status,
            score: quiz.score,
            livesRemaining: quiz.livesRemaining,
            signs: quiz.quiz.signs.map((sign) => {
              return {
                ...sign.sign,
                options: sign.options
              }
            }),
          }
        }),

        "matchingQuizes": userQuizes?.quizzes.filter((quiz) => quiz.quiz.type === QuizType.Matching).map((quiz) => {
          return {
            id: quiz.quiz.id,
            title: quiz.quiz.title,
            type: quiz.quiz.type,
            status: quiz.status,
            score: quiz.score,
            livesRemaining: quiz.livesRemaining,
            pairs: quiz.quiz.pairs.map((pair) => {
              return {
                id: pair.pair.id,
                text: pair.pair.text,
                signGif: pair.pair.signGif,
                matchIndex: pair.matchIndex,
              }
            }),
          }
        }),

        "alphabetQuizes": userQuizes?.quizzes.filter((quiz) => quiz.quiz.type === QuizType.AlphabetStreak).map((quiz) => {
          return {
            id: quiz.quiz.id,
            title: quiz.quiz.title,
            type: quiz.quiz.type,
            status: quiz.status,
            score: quiz.score,
            livesRemaining: quiz.livesRemaining,
            signs: quiz.quiz.signs.map((sign) => {
              return {
                ...sign.sign,
                options: sign.options
              }
            }),
          }
        }),
      }
    }
  }

  async completeQuiz(completeQuizDTO: CompleteQuizDTO, user: User) {
    const userData = await this.prisma.user.findUnique({
      where: {
        username: user.username,
      }
    });
    if (!userData) {
      throw new Error('User not found');
    }
    try {
      if (completeQuizDTO.status === QuizStatus.Completed) {
        const latestCompletedQuiz = await this.prisma.quizUser.findFirst({
          where: {
            userID: userData.id,
            status: QuizStatus.Completed
          },
          orderBy: {
            answeredAt: 'desc'
          }
        });

        const today = new Date();
        today.setHours(0, 0, 0, 0);

        const yesterday = new Date(today);
        yesterday.setDate(yesterday.getDate() - 1);

        if (latestCompletedQuiz && latestCompletedQuiz.answeredAt) {
          const latestDate = new Date(latestCompletedQuiz.answeredAt);
          latestDate.setHours(0, 0, 0, 0);
          
          // Compare the dates (as timestamps)
          const completedToday = latestDate.getTime() === today.getTime();
          const completedYesterday = latestDate.getTime() === yesterday.getTime();
          if (completedYesterday && !completedToday) {
            await this.prisma.user.update({
              where: {
                id: userData.id,
              },
              data: {
                streak: {
                  increment: 1,
                },
              },
            });
          }
          
          else if (!completedYesterday && !completedToday) {
            await this.prisma.user.update({
              where: {
                id: userData.id,
              },
              data: {
                streak: 1,
              },
            });
          }
        } else {
          await this.prisma.user.update({
            where: {
              id: userData.id,
            },
            data: {
              streak: 1,
            },
          });
        }

      }

      return await this.prisma.quizUser.update({
        where: {
          userID_quizID: {
            userID: userData.id,
            quizID: completeQuizDTO.quizID,
          },
          status: {
            not: QuizStatus.Completed,
          }
        },
        data: {
          status: completeQuizDTO.status,
          livesRemaining: completeQuizDTO.livesRemaining,
          score: +completeQuizDTO.score,
          answeredAt: new Date(),
        },
        select: {
          status: true
        }
      });
    }
    catch (error) {
      if (error.code === 'P2025') {
        throw new HttpException('Quiz not found or already completed', 400);
      } else {
        throw error;
      }
    }
  }
}
