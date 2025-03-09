import { Inject, Injectable } from '@nestjs/common';
import { DRIZZLE } from './db/drizzle.module';
import { mediumint } from 'drizzle-orm/mysql-core';
import { DrizzleDB } from './db/types/drizzle';


@Injectable()
export class AppService {
  constructor(@Inject(DRIZZLE) private db: DrizzleDB) {}
  
  async getHello() {
    return { message: 'Hello World!' };
  }
}
