import { Module } from '@nestjs/common';
import { QuizesService } from './quizes.service';
import { QuizController } from './quizes.controller';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [QuizController],
  providers: [QuizesService],
})
export class QuizesModule {}
