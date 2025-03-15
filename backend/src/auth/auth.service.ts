// 3. Create auth.service.ts
import { Injectable, UnauthorizedException } from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { UsersService } from '../users/users.service';
import * as bcrypt from 'bcrypt';

@Injectable()
export class AuthService {
  constructor(
    private usersService: UsersService,
    private jwtService: JwtService,
  ) {}

  async validateUser(emailOrUsername: string, password: string) {
    let user = await this.usersService.findByEmail(emailOrUsername);
    if (!user) {
      user = await this.usersService.findByUsername(emailOrUsername);
      if (!user) {
        return null;
      }
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      return null;
    }

    const { password: excludedPassword, id: excludedId, ...result } = user;
    return result;
  }

  async login(user: any) {
    const payload = { username: user.username, sub: user.id };
    return {
      accessToken: this.jwtService.sign(payload),
      user: user,
    };
  }

  async register(userData: {
    username: string;
    password: string;
    email: string;
  }) {
    const newUser = await this.usersService.create(userData);
    const { password: _, ...result } = newUser;
    return result;
  }

  async getProfile(user: any) {
    return await this.usersService.findByUsername(user.username);
  }
}
