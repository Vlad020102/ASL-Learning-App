import { Module } from '@nestjs/common';
import { QuizesService } from './quizes.service';
import { QuizController } from './quizes.controller';
import { PrismaModule } from 'src/prisma/prisma.module';
import { BadgesModule } from 'src/badges/badges.module';
import { BadgesService } from 'src/badges/badges.service';

@Module({
  imports: [PrismaModule, BadgesModule],
  controllers: [QuizController],
  providers: [QuizesService, BadgesService],
})
export class QuizesModule {}
