import { Injectable } from '@nestjs/common';
import { CreatePhraseDto } from './dto/create-phrase.dto';
import { UpdatePhraseDto } from './dto/update-phrase.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { User } from '@prisma/client';
import { PrismaClientUnknownRequestError } from '@prisma/client/runtime/library';

@Injectable()
export class PhrasesService {
    constructor(private readonly prisma: PrismaService) {}
    create(createPhraseDto: CreatePhraseDto) {
        return 'This action adds a new phrase';
    }

    async populatePhrases(userID: number) {
        const userPhrases = await this.prisma.userPhrase.findMany({
            where: { userID: userID },
        });

        const phrases = await this.prisma.phrase.findMany({})

        const filteredPhrases = phrases.filter((phrase) => {
            return !userPhrases.some((userPhrase) => userPhrase.phraseID === phrase.id);
        });

        for (const phrase of filteredPhrases) {
            await this.prisma.userPhrase.create({
                data: {
                    phrase: {
                        connect: {
                            id: phrase.id
                        }
                    },
                    user: {
                        connect: {
                            id: userID
                        }
                    },
                }
            })
        }
    }
    async findAll(userID: number) {
        // Get phrases with their signs and user statuses in a single query
        const phrases = await this.prisma.phrase.findMany({
            include: {
                signs: {
                    include: {
                        sign: true
                    }
                },
                userPhrases: {
                    where: {
                        userID: userID
                    },
                    select: {
                        status: true
                    }
                }
            }
        });
    
        // Transform the data structure
        const formattedPhrases = phrases.map(phrase => {

            const status = phrase.userPhrases[0]?.status || null;
            const { userPhrases, ...phraseWithoutUserPhrases } = phrase;
            return {
                ...phraseWithoutUserPhrases,
                status,
                explanation: phrase.explanation ? phrase.explanation.split(', ') : [],
                signs: phrase.signs.map(signRelation => ({
                    ...signRelation.sign,
                    explanation: signRelation.sign?.explanation 
                    ? signRelation.sign.explanation.split(', ') 
                    : []
                }
                ))
            };
        });
    
        // Extract unique signs
        const uniqueSigns = Array.from(
            new Map(
                phrases
                    .flatMap(phrase => phrase.signs.map(rel => rel.sign).filter(Boolean))
                    .map(sign => [sign?.id, {
                        ...sign,
                        explanation: sign?.explanation 
                            ? sign.explanation.split(', ') 
                            : []
                    }])
            ).values()
        );
    
        return {
            phrases: formattedPhrases,
            signs: uniqueSigns
        };
    }

    async findOne(id: number) {
        return await this.prisma.phrase.findUnique({
            where: { id },
            include: {
                signs: {
                    include: {
                        sign: true
                    }
                }
            }
        });
    }

    update(id: number, updatePhraseDto: UpdatePhraseDto) {
        return `This action updates a #${id} phrase`;
    }

    remove(id: number) {
        return `This action removes a #${id} phrase`;
    }
}
