import { Module } from '@nestjs/common';
import { QuizesService } from './quizes.service';
import { QuizController } from './quizes.controller';
import { PrismaModule } from 'src/prisma/prisma.module';
import { BadgesModule } from 'src/badges/badges.module';
import { BadgesService } from 'src/badges/badges.service';
import { UsersModule } from 'src/users/users.module';
import { UsersService } from 'src/users/users.service';
import { SharedCacheModule } from 'src/cache/cache.module';

@Module({
  imports: [PrismaModule, BadgesModule, UsersModule, SharedCacheModule],
  controllers: [QuizController],
  providers: [QuizesService, BadgesService, UsersService],
})
export class QuizesModule {}
