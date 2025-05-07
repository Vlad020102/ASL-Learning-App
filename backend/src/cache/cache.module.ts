import { Module } from '@nestjs/common';
import { CacheModule } from '@nestjs/cache-manager';
import { createKeyv } from '@keyv/redis';
import { CacheableMemory } from 'cacheable';
import Keyv from 'keyv';

@Module({
  imports: [
    CacheModule.registerAsync({
        useFactory: async () => {
          return {
            stores: [
              new Keyv({
                store: new CacheableMemory({ ttl: 60000, lruSize: 5000 }),
              }),
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
