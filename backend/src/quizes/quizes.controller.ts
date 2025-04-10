import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req } from '@nestjs/common';
import { QuizesService } from './quizes.service';
import { JwtAuthGuard } from 'src/auth/guards/jwt.guard';
import { ReqUser } from 'src/auth/guards/user.decorator';
import { CompleteQuizDTO } from './entities/completeQuiz';
import { BadgesService } from 'src/badges/badges.service';

@Controller('quizes')
export class QuizController {
  constructor(private readonly quizesService: QuizesService, private readonly badgesService: BadgesService) {}
  @Get()
  @UseGuards(JwtAuthGuard)
  findAll(@ReqUser() user) {
    console.log(user);
    this.quizesService.populateQuiz(user);
    return this.quizesService.findAllQuizesForUser(user);
  } 

  @Patch('complete-quiz')
  @UseGuards(JwtAuthGuard)
  async completeQuiz(@Param('id') id: string, @ReqUser() user, @Body() completeQuizDTO: CompleteQuizDTO) {
    console.log(user);
    const response = await this.quizesService.completeQuiz(completeQuizDTO, user);
    await this.badgesService.checkIfBadgeEligible(user.id);
    return response
  }
}
