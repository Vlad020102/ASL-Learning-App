import { Injectable } from '@nestjs/common';
import { CreatePhraseDto } from './dto/create-phrase.dto';
import { UpdatePhraseDto } from './dto/update-phrase.dto';
import { PrismaService } from 'src/prisma/prisma.service';

@Injectable()
export class PhrasesService {
    constructor(private readonly prisma: PrismaService) {}
    create(createPhraseDto: CreatePhraseDto) {
        return 'This action adds a new phrase';
    }

    async findAll() {
        const phrases =  await this.prisma.phrase.findMany({
            include: {
                words: {
                    include: {
                        word: true
                    }
                }
            }
        });

        return phrases.map(phrase => ({
            ...phrase,
            explanation: phrase.explanation?.split(', ') ?? [],
            words: phrase.words.map(word => ({
                ...word.word,
            }))
        }));
    }

    async findOne(id: number) {
        return await this.prisma.phrase.findUnique({
            where: { id },
            include: {
                words: {
                    include: {
                        word: true
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
