import { HttpException, Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';
import { QuizStatus, User } from '@prisma/client';
import { CompleteQuizDTO } from './entities/completeQuiz';

@Injectable()
export class QuizesService {
  constructor(private prisma: PrismaService) {}
  async populateQuiz(user) {
    const userQuizes = await this.prisma.quiz.findMany({
      include: {
        users: {
          where: {
            user:{
              username: user.username
            }
          },
        },
        signs: {
          select:{
            sign:true
          }
        }
      }
    });

    const quizes = await this.prisma.quiz.findMany({})
    const filteredQuizes = quizes.filter((quiz) => {
      return !userQuizes.some((userQuiz) => userQuiz.id === quiz.id);
    });

    if(userQuizes.length === 0){
      return userQuizes
    }else{
      for(const quiz of filteredQuizes){
       await this.prisma.quizUser.create({
          data:{
            quiz: {
              connect:{
                id: quiz.id
              }
            },
            user: {
              connect:{
                username: user.username
              }
            },
          }
        })
       }
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
                  }
                },
              },
            },
          }
        },
      },
    });
    return {
      "quizes": userQuizes?.quizzes.map((quiz) => {
        return {
          id: quiz.quiz.id,
          title: quiz.quiz.title,
          type: quiz.quiz.type,
          status: quiz.status,
          score: quiz.score,
          livesRemaining: quiz.livesRemaining,
          signs: quiz.quiz.signs.map((sign) => sign.sign),
        }
      })
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
    try{
      return await this.prisma.quizUser.update({
        where: {
          user_id_quiz_id: {
            user_id: userData.id,
            quiz_id: completeQuizDTO.quizId,
          },
          status: {
            not: QuizStatus.Completed,
          }
        },
        data: {
          status: completeQuizDTO.status,
          livesRemaining: completeQuizDTO.livesRemaining,
          score: +completeQuizDTO.score,
        },
        select: {
          status: true
        }
      }); 
    }
    catch (error) {
      if (error.code === 'P2025') {
        throw new HttpException('Quiz not found or already completed', 404);
      } else {
        throw error;
      }
    }
  }
}
