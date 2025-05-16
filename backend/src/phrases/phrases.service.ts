import { HttpException, HttpStatus, Injectable } from '@nestjs/common';
import { CreatePhraseDto } from './dto/create-phrase.dto';
import { PrismaService } from 'src/prisma/prisma.service';
import { PhraseStatus, User } from '@prisma/client';
import { Cache } from '@nestjs/cache-manager';
import { Inject } from '@nestjs/common';

@Injectable()
export class PhrasesService {
    constructor(
        private readonly prisma: PrismaService,
        @Inject('CACHE_MANAGER') private cacheManager: Cache
    ) {}
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

        const user = await this.prisma.user.findUnique({
            where: { id: userID }
        });

        // Transform phrases first as before
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
                }))
            };
        });

        // Create a map of signs with their related phrases
        const signPhrasesMap = new Map();
        phrases.forEach(phrase => {
            phrase.signs.forEach(({ sign }) => {
                if (!sign) return;
                
                const existingPhrases = signPhrasesMap.get(sign.id) || [];
                signPhrasesMap.set(sign.id, [...existingPhrases, phrase.name]);
            });
        });

        // Create uniqueSigns with related phrases
        const uniqueSigns = Array.from(
            new Map(
                phrases
                    .flatMap(phrase => phrase.signs.map(rel => rel.sign).filter(Boolean))
                    .map(sign => [sign?.id, {
                        ...sign,
                        explanation: sign?.explanation 
                            ? sign.explanation.split(', ') 
                            : [],
                        usedIn: signPhrasesMap.get(sign?.id) || []
                    }])
            ).values()
        );

        return {
            phrases: formattedPhrases,
            signs: uniqueSigns,
            money: user?.money || 0,
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
    
    async purchase(phrase_id: number, user_id: number, price: number ) {
        await this.cacheManager.mdel(['/phrases', '/users/profile']);
        if (price <= 0) {
            throw new HttpException({
                status: HttpStatus.BAD_REQUEST,
                error: 'Price must be greater than 0',
            }, HttpStatus.BAD_REQUEST);
        }

        const user = await this.prisma.user.findUnique({
            where: { id: user_id }
        });
        
        if (!user) {
            throw new HttpException({
                status: HttpStatus.NOT_FOUND,
                error: 'User not found',
            }, HttpStatus.NOT_FOUND);
        }

        if (user.money < price) {
            throw new HttpException({
                status: HttpStatus.BAD_REQUEST,
                error: 'Not enough money',
            }, HttpStatus.BAD_REQUEST);
        }   

        try {
            let phrase = await this.prisma.phrase.findUnique({
                where: { id: phrase_id },
                include: {
                    signs: {
                        include: {
                            sign: true
                        }
                    },
                    userPhrases: {
                        where: {
                            userID: user_id
                        },
                        select: {
                            status: true
                        }
                    }
                }
            });
            if (!phrase) {
                throw new HttpException({
                    status: HttpStatus.NOT_FOUND,
                    error: 'Phrase not found',
                }, HttpStatus.NOT_FOUND);
            }
            const status = phrase.userPhrases[0]?.status || null;

            if (status === PhraseStatus.Purchased) {
                throw new HttpException({
                    status: HttpStatus.BAD_REQUEST,
                    error: 'Phrase already purchased',
                }, HttpStatus.BAD_REQUEST);
            }

            await this.prisma.userPhrase.update({
                where: {
                    userID_phraseID: {
                        userID: user_id,
                        phraseID: phrase_id
                    }
                },
                data: {
                    status: PhraseStatus.Purchased
                }
            });

            await this.prisma.user.update({
                where: { id: user_id },
                data: {
                    money: user.money - price
                }
            });

            return {
    
                ...phrase,
                userPhrases: undefined,
                status: PhraseStatus.Purchased,
                explanation: phrase.explanation ? phrase.explanation.split(', ') : [],
                signs: phrase.signs.map(signRelation => ({
                    ...signRelation.sign,
                    explanation: signRelation.sign?.explanation 
                    ? signRelation.sign.explanation.split(', ') 
                    : []
                }))
            }

        } catch (error) {
            throw new HttpException({
                status: HttpStatus.NOT_FOUND,
                error: error.response?.error || 'An error occurred while processing your request',
            }, HttpStatus.NOT_FOUND);
        }
    }
}
