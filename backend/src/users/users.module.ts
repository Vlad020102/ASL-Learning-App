import { Module } from '@nestjs/common';
import { UsersService } from './users.service';
import { UsersController } from './users.controller';
import { PrismaModule } from 'src/prisma/prisma.module';
import { SharedCacheModule } from 'src/cache/cache.module';

@Module({
  imports: [PrismaModule, SharedCacheModule],
  controllers: [UsersController],
  providers: [UsersService],
})
export class UsersModule {}
