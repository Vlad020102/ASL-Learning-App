import { Inject, Injectable } from '@nestjs/common';
import { NodePgDatabase } from 'drizzle-orm/node-postgres';
import * as schema from './schema/schema';
import { DRIZZLE } from './drizzle/drizzle.module';
import { mediumint } from 'drizzle-orm/mysql-core';


@Injectable()
export class AppService {
  constructor(@Inject(DRIZZLE) private db:  NodePgDatabase<typeof schema>) {}
  
  async getHello() {
    return await this.db.query.posts.findFirst({});
  }

  async insertPost() {
    return await this.db.insert(schema.posts).values({
        authorId: 1,
        content: 'This is my first post.',
        mediaUrl: 'https://example.com/image.jpg',
    }).returning();
  }
}
