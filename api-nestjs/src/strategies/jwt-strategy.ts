import { Injectable, UnauthorizedException } from '@nestjs/common';
import { PassportStrategy } from '@nestjs/passport';
import { Types } from 'mongoose';
import _ from 'lodash';

import { ExtractJwt, Strategy } from 'passport-jwt';
import { UserService } from 'src/apis/user/user.service';
import { UserPayload } from 'src/base/models/user-payload.model';
import { appSettings } from 'src/configs/app-settings';

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(private userService: UserService) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: appSettings.jwt.secret,
    });
  }

  async validate(payload: UserPayload) {
    const { _id } = payload;

    const user = await this.userService.getOne({
      _id: new Types.ObjectId(_id),
    });

    if (!user) {
      throw new UnauthorizedException('Unauthorized');
    }

    return {
      ...payload,
    };
  }
}
