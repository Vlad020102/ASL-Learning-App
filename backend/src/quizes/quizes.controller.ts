import { QuizesService } from './quizes.service';
import { Controller, Get, Body, Patch, Param, UseGuards } from '@nestjs/common';
import { JwtAuthGuard } from 'src/auth/guards/jwt.guard';
import { ReqUser } from 'src/auth/guards/user.decorator';
import { CompleteQuizDTO } from './dto/completeQuiz';
import { BadgesService } from 'src/badges/badges.service';
import { UsersService } from 'src/users/users.service';
import { QuizStatus } from '@prisma/client';
import { UseInterceptors } from '@nestjs/common';
import { CacheInterceptor, CacheTTL } from '@nestjs/cache-manager';


@Controller('quizes')
export class QuizController {
  constructor(
    private readonly quizesService: QuizesService,
    private readonly badgesService: BadgesService,
    private readonly userService: UsersService,
  ) {}
  @Get()
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(CacheInterceptor)
  findAll(@ReqUser() user) { 
    this.quizesService.populateQuiz(user);
    return this.quizesService.findAllQuizesForUser(user);
  } 

  @Patch('complete-quiz')
  @UseGuards(JwtAuthGuard)
  async completeQuiz(@Param('id') id: string, @ReqUser() user, @Body() completeQuizDTO: CompleteQuizDTO) {
    const response = await this.quizesService.completeQuiz(completeQuizDTO, user);
    if(completeQuizDTO.status == QuizStatus.Completed) {
      const updatedUserFirst = await this.userService.updateUserLevel(user.user, +completeQuizDTO.score, +completeQuizDTO.livesRemaining, +completeQuizDTO.quizID);
      const updatedUserSecond = await this.userService.updateUserQuestionsAnswered(updatedUserFirst);
      await this.badgesService.completePossibleBadges(updatedUserSecond);
    }
    return response
  }
}
