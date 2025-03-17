import { BadRequestException, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { JwtService } from '@nestjs/jwt';
import { UserLoginDto } from './dto/user-login.dto';
import { UserRegisterDto } from './dto/user-register.dto';
import { UserService } from '../user/user.service';
import { appSettings } from 'src/configs/app-settings';
import { UserPayload } from 'src/base/models/user-payload.model';
// import { CheckPasswordDto } from './dto/check-password.dto';
import { Types } from 'mongoose';

@Injectable()
export class AuthService {
  constructor(
    private jwtService: JwtService,
    private userService: UserService,
  ) {}

  async verifyPassword(
    plainPassword: string,
    hashedPassword: string,
  ): Promise<boolean> {
    return bcrypt.compare(plainPassword, hashedPassword);
  }

  async register(userRegister: UserRegisterDto) {
    try {
      const { username, email, password } = userRegister;

      var existingUser = await this.userService.getOne({ username });

      if (existingUser)
        throw new BadRequestException('Tên đã được người khác sử dụng');

      var existingUserEmail = await this.userService.getOne({ email });

      if (existingUserEmail) throw new BadRequestException('Email đã tồn tại');

      const hashedPassword = await bcrypt.hash(password, 10);

      await this.userService.creatOne({
        username,
        email,
        password: hashedPassword,
      });
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  async login(userLogin: UserLoginDto) {
    const { email, password } = userLogin;

    const user = await this.userService.getOne({ email });

    if (!user) {
      throw new BadRequestException('Invalid email or password');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);

    if (!isPasswordValid) {
      throw new BadRequestException('Invalid email or password');
    }

    const userPayload: UserPayload = {
      _id: new Types.ObjectId(user._id),
      email: user.email,
      username: user.username,
    };

    const token = await this.getTokens(userPayload);
    return token;
  }

  private async getTokens(user: UserPayload) {
    const { _id, email, username } = user;

    const payload = { _id, email, username };

    const [refreshToken, accessToken] = await Promise.all([
      this.jwtService.signAsync(payload, {
        expiresIn: appSettings.jwt.refreshExpireIn,
        secret: appSettings.jwt.refreshSecret,
      }),
      this.jwtService.signAsync(payload, {
        expiresIn: appSettings.jwt.expireIn,
        secret: appSettings.jwt.secret,
      }),
    ]);

    return {
      accessToken,
      refreshToken,
    };
  }

  // async checkPassword(checkDto: CheckPasswordDto) {
  //   try {
  //     const existingUser = await this.userService.getOne({
  //       _id: new Types.ObjectId(checkDto.user),
  //     });

  //     const isPasswordValid = await bcrypt.compare(
  //       checkDto.password,
  //       existingUser.password,
  //     );

  //     if (!isPasswordValid) {
  //       throw new BadRequestException('Invalid email or password');
  //     }
  //   } catch (error) {
  //     throw new BadRequestException(error);
  //   }
  // }
}
