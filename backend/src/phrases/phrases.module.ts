import { Module } from '@nestjs/common';
import { PhrasesService } from './phrases.service';
import { PhrasesController } from './phrases.controller';
import { PrismaModule } from 'src/prisma/prisma.module';
import { SharedCacheModule } from 'src/cache/cache.module';

@Module({
  imports: [PrismaModule, SharedCacheModule],
  controllers: [PhrasesController],
  providers: [PhrasesService],
})
export class PhrasesModule {}
