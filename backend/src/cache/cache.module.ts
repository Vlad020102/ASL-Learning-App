import { Module } from '@nestjs/common';
import { CacheModule } from '@nestjs/cache-manager';
import { createKeyv } from '@keyv/redis';
import { CacheableMemory } from 'cacheable';
import Keyv from 'keyv';

@Module({
  imports: [
    CacheModule.registerAsync({
        isGlobal: true,
        useFactory: async () => {
          return {
            stores: [
              createKeyv('redis://localhost:6379')
            ],
          };
        },
      }),
  ],
  controllers: [],
  providers: [],
  exports: [CacheModule],
})
export class SharedCacheModule {}
