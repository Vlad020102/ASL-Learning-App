import { Module } from '@nestjs/common';
import { PrismaModule } from './prisma/prisma.module';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { BadgesModule } from './badges/badges.module';
import { QuizesModule } from './quizes/quizes.module';
import { PhrasesModule } from './phrases/phrases.module';
import { CacheInterceptor, CacheModule } from '@nestjs/cache-manager';
import { createKeyv } from '@keyv/redis';
import { CacheableMemory } from 'cacheable';
import Keyv from 'keyv';
import { APP_INTERCEPTOR } from '@nestjs/core';
import { SharedCacheModule } from './cache/cache.module';


@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    AuthModule,
    UsersModule,
    BadgesModule,
    PrismaModule,
    QuizesModule,
    PhrasesModule,
    SharedCacheModule
  ],
  controllers: [],
  providers: [
    // {
    // provide: APP_INTERCEPTOR,
    // useClass: CacheInterceptor
    // }
  ]
})
export class AppModule {}
