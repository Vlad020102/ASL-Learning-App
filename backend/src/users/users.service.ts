import {
  Injectable,
  ConflictException,
  NotFoundException,
} from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { CreateUserDto } from './dto/create-user.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { User } from '@prisma/client';

@Injectable()
export class UsersService {
  constructor(private readonly prisma: PrismaService) {}

  async findOne(id: number) {
    return await this.prisma.user.findUnique({
      where: { id },
    });
  }

  async create(userData: CreateUserDto) {
    const existingUser = await this.findByUsername(userData.username);
    if (existingUser) {
      throw new ConflictException('Username already exists');
    }

    const hashedPassword = await bcrypt.hash(userData.password, 10);

    return await this.prisma.user.create({
      data: {
        ...userData,
        password: hashedPassword,
      },
    });
  }

  async findAll() {
    return await this.prisma.user.findMany();
  }

  async findByUsername(username: string) {
    if (username === '') return null;
    return await this.prisma.user.findUnique({
      where: { username },
    });
  }

  async findByEmail(email: string) {
    if (email === '') return null;
    return await this.prisma.user.findUnique({
      where: { email },
    });
  }

async findProfile(user: User) {
    const userWithBadges = await this.prisma.user.findUnique({
      where: { username: user.username },
      include: {
      badges: {
        select: {
        id: true,
        progress: true,
        status: true,
        badge: {
          select: {
          name: true,
          description: true,
          icon: true,
          type: true,
          rarity: true,
          },
        },
        }
      },
      },
    });

    const userProfile = userWithBadges ? {
      ...userWithBadges,
      badges: userWithBadges.badges.map(badge => ({
        id: badge.id,
        progress: badge.progress,
        status: badge.status,
        ...badge.badge,
      })),
    } : null;
    if (!userProfile) {
      throw new NotFoundException('User not found');
    }

    const { id, password, ...profileWithoutId } = userProfile;
    return profileWithoutId;
  }

  async getUserBadges(user: any) {
    const userBadges = await this.prisma.userBadge.findMany({
      where: {
        user:{
          username: user.username,
        }
      },
    });
    const badges = await this.prisma.badge.findMany({})
    if (userBadges.length == badges.length) 
      return userBadges;
    else {
      for (const badge of badges) {
        await this.prisma.userBadge.create({
          data: {
            user: {
              connect: {
                username: user.username,
              },
            },
            badge:{
              connect: {
                id: badge.id,
              },
            }
          },
        });
      }
      }
    }
}

