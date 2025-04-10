import { Injectable } from '@nestjs/common';
import { CreateBadgeDto } from './dto/create-badge.dto';
import { UpdateBadgeDto } from './dto/update-badge.dto';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class BadgesService {
  constructor(private readonly  prisma: PrismaService) {}

  async checkIfBadgeEligible(userId: string) {

    const userBadges = await this.prisma.userBadge.findMany({
      where: {
        userID: +userId
      },
      include: {
        badge: {
          select: {
            id: true,
            name: true,
            rarity: true,
            type: true,
            icon: true,
            description: true,
          }
        }
      }
    })

    
  }
}
