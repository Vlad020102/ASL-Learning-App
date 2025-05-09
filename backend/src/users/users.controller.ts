import {
  Controller,
  Get,
  Post,
  Body,
  UseGuards
} from '@nestjs/common';
import { UsersService } from './users.service';
import { CreateUserDto } from './dto/create-user.dto';
import { JwtAuthGuard } from 'src/auth/guards/jwt.guard';
import { ReqUser } from 'src/auth/guards/user.decorator';
import { User } from '@prisma/client';

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
  @Get('profile')
  findProfile(
    @ReqUser() user: User
  ) {
    this.usersService.getUserBadges(user);
    return this.usersService.findProfile(user);
  }

  @UseGuards(JwtAuthGuard)
  @Get('streaks')
  getStreaks(
    @ReqUser() user: User
  ) {
    return this.usersService.getStreaks(user);
  }
}
