import { Module } from '@nestjs/common';
import { ExploreService } from './explore.service';
import { ExploreController } from './explore.controller';
import { PrismaModule } from 'src/prisma/prisma.module';

@Module({
  imports: [PrismaModule],
  controllers: [ExploreController],
  providers: [ExploreService],
})
export class ExploreModule {}
