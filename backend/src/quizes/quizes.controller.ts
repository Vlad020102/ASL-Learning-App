import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards, Req } from '@nestjs/common';
import { QuizesService } from './quizes.service';
import { JwtAuthGuard } from 'src/auth/guards/jwt.guard';
import { ReqUser } from 'src/auth/guards/user.decorator';
import { CompleteQuizDTO } from './entities/completeQuiz';

@Controller('quizes')
export class QuizController {
  constructor(private readonly quizesService: QuizesService) {}
  @Get()
  @UseGuards(JwtAuthGuard)
  findAll(@ReqUser() user) {
    this.quizesService.populateQuiz(user);
    return this.quizesService.findAllQuizesForUser(user);
  } 

  @Patch('complete-quiz')
  @UseGuards(JwtAuthGuard)
  completeQuiz(@Param('id') id: string, @ReqUser() user, @Body() completeQuizDTO: CompleteQuizDTO) {
    return this.quizesService.completeQuiz(completeQuizDTO, user);
  }
}
