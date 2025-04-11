import { Injectable } from '@nestjs/common';
import { CreateBadgeDto } from './dto/create-badge.dto';
import { UpdateBadgeDto } from './dto/update-badge.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { Badge, BadgeStatus, BadgeType, User } from '@prisma/client';


@Injectable()
export class BadgesService {
  constructor(private readonly  prisma: PrismaService) {}

  async completePossibleBadges(user: User) {
    const userBadges = await this.prisma.userBadge.findMany({
      where: {
        userID: +user.id
      },
      select:{        
        badge: {
          select: {
            id: true,
            name: true,
            rarity: true,
            type: true,
            icon: true,
            description: true,
            target: true,
          }
        },
        user: {
          select: {
            id: true,
            username: true,
            level: true,
            questionsAnsweredTotal: true,
          }
        },
        status: true,
      }
    })

    const uncompletedBadges = userBadges.filter((userBadge) => userBadge.status === BadgeStatus.InProgress).map((userBadge) => userBadge.badge);
    uncompletedBadges.forEach(async (badge) => {
      this.completeBadge(badge, user);
    })
  }


  private async completeBadge(badge: Badge, user: User) {
    if(badge.type === BadgeType.Level) {
      this.completeLevelBadge(badge, user);
    } else if(badge.type === BadgeType.Question) {
      this.completeQuestionBadge(badge, user);
    }
  }

  private async completeLevelBadge(badge: Badge, user: User) {
    if(user.level_progress >= badge.target) {
      await this.prisma.userBadge.update({
        where: {
          userID_badgeID: {
            userID: user.id,
            badgeID: badge.id
          }
        },
        data: {
          status: BadgeStatus.Completed,
          progress: 100
        }
      })
    }
    else if(user.level < badge.target) {
      await this.prisma.userBadge.update({
        where: {
          userID_badgeID: {
        userID: user.id,
        badgeID: badge.id
          }
        },
        data: {
          status: BadgeStatus.InProgress,
          progress: Math.round((user.level_progress * 100 / badge.target) * 100) / 100
        }
      })
    }
  }

  private async completeQuestionBadge(badge: Badge, user: User) {
    if(user.questionsAnsweredTotal >= badge.target) {
      await this.prisma.userBadge.update({
        where: {
          userID_badgeID: {
            userID: user.id,
            badgeID: badge.id
          }
        },
        data: {
          status: BadgeStatus.Completed,
          progress: 100
        }
      })
    }
    else if(user.questionsAnsweredTotal < badge.target) {
      await this.prisma.userBadge.update({
        where: {
          userID_badgeID: {
            userID: user.id,
            badgeID: badge.id
          }
        },
        data: {
          status: BadgeStatus.InProgress,
          progress:  Math.round((user.questionsAnsweredTotal * 100 / badge.target) * 100) / 100
        }
      })
    }
  }
}

