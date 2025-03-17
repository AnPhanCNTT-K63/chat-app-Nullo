import { Module } from '@nestjs/common';
import { JwtModule } from '@nestjs/jwt';
import { appSettings } from 'src/configs/app-settings';

@Module({
  imports: [
    UsersModule,
    JwtModule.register({
      secret: appSettings.jwt.secret,
      signOptions: {
        expiresIn: appSettings.jwt.expireIn,
        issuer: appSettings.jwt.issuer,
      },
    }),
  ],
  controllers: [],
  providers: [],
  exports: [],
})
export class UsersModule {}
