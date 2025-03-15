import {
  Controller,
  Post,
  Body,
  UseGuards,
  Request,
  Get,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthService } from './auth.service';
import { JwtAuthGuard } from './guards/jwt.guard';
import { LoginUserDto } from './dto/login.dto';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('login')
  async login(@Body() loginUserDto: LoginUserDto) {
    const user = await this.authService.validateUser(
      loginUserDto.emailOrUsername ? loginUserDto.emailOrUsername : '',
      loginUserDto.password,
    );
    if (!user) {
      throw new UnauthorizedException(
        'No user was found with the provided credentials',
      );
    }

    return this.authService.login(user);
  }

  @Post('register')
  async register(
    @Body() registerDto: { username: string; password: string; email: string },
  ) {
    return this.authService.register(registerDto);
  }

  @UseGuards(JwtAuthGuard)
  @Get('profile')
  getProfile(@Request() req) {
    return this.authService.getProfile(req.user);
  }
}
