import { Controller, Get, Inject, Post } from '@nestjs/common';
import { AppService } from './app.service';

@Controller()
export class AppController {
  constructor(private readonly appService: AppService) {}
  @Get()
  getHello() {
    return this.appService.getHello();
  }

  @Post()
  insertPost() {
    return this.appService.insertPost();
  }
}
