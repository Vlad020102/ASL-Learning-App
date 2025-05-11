import { Controller, Get, UseGuards } from '@nestjs/common';
import { ExploreService } from './explore.service';
import { JwtAuthGuard } from 'src/auth/guards/jwt.guard';
import { ReqUser } from 'src/auth/guards/user.decorator';

@Controller('explore')
export class ExploreController {
  constructor(private readonly exploreService: ExploreService) {}

  @Get()
  @UseGuards(JwtAuthGuard)
  async getExplore(@ReqUser() user) {
    return this.exploreService.getExplore(user.user.referralCode);
  }
}


