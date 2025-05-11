import { Controller, Get, Post, Body, Patch, Param, Delete, UseGuards } from '@nestjs/common';
import { PhrasesService } from './phrases.service';
import { CreatePhraseDto } from './dto/create-phrase.dto';
import { PurchasePhraseDto } from './dto/purchase-phrase.dto';
import { ReqUser } from 'src/auth/guards/user.decorator';
import { JwtAuthGuard } from 'src/auth/guards/jwt.guard';
import { UseInterceptors } from '@nestjs/common';
import { CacheInterceptor } from '@nestjs/cache-manager';

@Controller('phrases')
export class PhrasesController {
    constructor(private readonly phrasesService: PhrasesService) {}

    @Post()
    create(@Body() createPhraseDto: CreatePhraseDto) {
        return this.phrasesService.create(createPhraseDto);
    }


    @Get()
    @UseGuards(JwtAuthGuard)
    @UseInterceptors(CacheInterceptor)
    findAll(@ReqUser() user) {
        this.phrasesService.populatePhrases(user.user.id);
        return this.phrasesService.findAll(user.user.id);
    }

    @Get(':id')
    findOne(@Param('id') id: string) {
        return this.phrasesService.findOne(+id);
    }

    @Post('purchase/:id')
    @UseGuards(JwtAuthGuard)
    async purchase(
        @Param('id') id: number,
        @ReqUser() user,
        @Body() purchasePhrase: PurchasePhraseDto
    ) {
        const result = await this.phrasesService.purchase(id, user.user.id, purchasePhrase.price);
        return result
    }
}
