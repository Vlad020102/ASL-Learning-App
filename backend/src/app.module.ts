import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { BadgesModule } from './badges/badges.module';
import { QuizesModule } from './quizes/quizes.module';

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    UsersModule,
    BadgesModule,
    PrismaModule,
    QuizesModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
