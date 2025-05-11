import { Injectable } from '@nestjs/common';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class ExploreService {
    constructor(private readonly prisma: PrismaService) { }

    async getExplore(referralCode: number) {
        const allExtras = await this.prisma.extras.findMany(
            {
                select: {
                    id: true,
                    title: true,
                    description: true,
                    type: true,
                    link: true,
                    imageUrl: true,
                }
            }
        );

        const groupedByType = allExtras.reduce((acc, extra) => {
            if (!acc[extra.type]) {
                acc[extra.type] = [];
            }
            acc[extra.type].push(extra);
            return acc;
        }, {});

        return {
            "extras": groupedByType,
            "referralCode": referralCode
        }
    }

}