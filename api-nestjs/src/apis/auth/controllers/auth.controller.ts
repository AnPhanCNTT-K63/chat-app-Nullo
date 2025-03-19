import { Body, Controller, Post, UseGuards } from '@nestjs/common';
import { AuthService } from '../auth.service';
import { UserLoginDto } from '../dto/user-login.dto';
import { UserRegisterDto } from '../dto/user-register.dto';
import { CheckPasswordDto } from '../dto/check-password.dto';
import { Me } from 'src/decorators/me.decorator';
import { UserPayload } from 'src/base/models/user-payload.model';
import { ApiBearerAuth } from '@nestjs/swagger';
import { JwtAuthGuard } from 'src/guards/jwt-auth.guard';

@Controller('auth')
export class AuthController {
  constructor(private authService: AuthService) {}

  @Post('signin')
  login(@Body() userLogin: UserLoginDto) {
    return this.authService.login(userLogin);
  }

  @Post('signup')
  register(@Body() userRegister: UserRegisterDto) {
    return this.authService.register(userRegister);
  }

  @ApiBearerAuth()
  @UseGuards(JwtAuthGuard)
  @Post('check-password')
  checkPassword(
    @Me() userPayload: UserPayload,
    @Body() checkDto: CheckPasswordDto,
  ) {
    return this.authService.checkPassword(userPayload, checkDto);
  }
}
