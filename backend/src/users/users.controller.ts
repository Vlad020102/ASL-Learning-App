import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards,
  UseInterceptors
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt.guard';
import { ReqUser } from 'src/auth/guards/user.decorator';
import { User } from '@prisma/client';
import { CacheInterceptor } from '@nestjs/cache-manager';

@Controller('users')
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Post()
  create(@Body() createUserDto: CreateUserDto) {
    return this.usersService.create(createUserDto);
  }

  @Get()
  findAll() {
    return this.usersService.findAll();
  }
  
  @UseGuards(JwtAuthGuard)
  @UseInterceptors(CacheInterceptor)
  @Get('profile')
  findProfile(
    @ReqUser() user: User
  ) {
    this.usersService.getUserBadges(user);
    return this.usersService.findProfile(user);
  }

  @UseGuards(JwtAuthGuard)
  @UseInterceptors(CacheInterceptor)
  @Get('streaks')
  getStreaks(
    @ReqUser() user: User
  ) {
    return this.usersService.getStreaks(user);
  }
}
