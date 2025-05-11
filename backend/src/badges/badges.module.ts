import { Module } from '@nestjs/common';
import { BadgesService } from './badges.service';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [],
  providers: [BadgesService],
})
export class BadgesModule {}
