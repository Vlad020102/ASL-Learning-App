// import { Controller, Get, Post, Body, Patch, Param, Delete } from '@nestjs/common';
// import { PhrasesService } from './phrases.service';
// import { CreatePhraseDto } from './dto/create-phrase.dto';
// import { UpdatePhraseDto } from './dto/update-phrase.dto';

// @Controller('phrases')
// export class PhrasesController {
//   constructor(private readonly phrasesService: PhrasesService) {}

//   @Post()
//   create(@Body() createPhraseDto: CreatePhraseDto) {
//     return this.phrasesService.create(createPhraseDto);
//   }

//   @Get()
//   findAll() {
//     return this.phrasesService.findAll();
//   }

//   @Get(':id')
//   findOne(@Param('id') id: string) {
//     return this.phrasesService.findOne(+id);
//   }

//   @Patch(':id')
//   update(@Param('id') id: string, @Body() updatePhraseDto: UpdatePhraseDto) {
//     return this.phrasesService.update(+id, updatePhraseDto);
//   }

//   @Delete(':id')
//   remove(@Param('id') id: string) {
//     return this.phrasesService.remove(+id);
//   }
// }
