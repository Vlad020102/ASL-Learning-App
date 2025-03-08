// 2. Create users.service.ts
import { Injectable, ConflictException, NotFoundException, Inject } from '@nestjs/common';
import { users } from '../db/schema/schema';
import { eq } from 'drizzle-orm';
import * as bcrypt from 'bcrypt';
import { DRIZZLE } from 'src/db/drizzle.module';
import { DrizzleDB } from 'src/db/types/drizzle';
import { CreateUserDto } from './dto/create-user.dto';

@Injectable()
export class UsersService {
  constructor(@Inject(DRIZZLE) private db: DrizzleDB) {}

  async findOne(id: number) {
    const result = await this.db.select().from(users).where(eq(users.id, id));
    return result[0] || null;
  }

  async create(userData: CreateUserDto){
    const existingUser = await this.findByUsername(userData.username);
    if (existingUser) {
      throw new ConflictException('Username already exists');
    }

    const hashedPassword = await bcrypt.hash(userData.password, 10);

    const result = await this.db.insert(users).values({
      ...userData,
      password: hashedPassword,
    }).returning()

    return result[0];
  }
  async findAll() {
    return await this.db.query.users.findMany();
  }

  async findByUsername(username: string) {
    const result = await this.db.select().from(users).where(eq(users.username, username));
    return result[0] || null;
  }

}