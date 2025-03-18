import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { appSettings } from './configs/app-settings';
import { ConfigModule } from '@nestjs/config';
import { AuthModule } from './apis/auth/auth.module';
import { UsersModule } from './apis/user/user.module';
import { MediaModule } from './apis/media/media.module';
import { ProfileModule } from './apis/profile/profile.module';

@Module({
  imports: [
    ConfigModule.forRoot({
      isGlobal: true,
    }),
    MongooseModule.forRootAsync({
      useFactory: async () => ({
        uri: appSettings.mongoose.uri,
      }),
    }),
    AuthModule,
    UsersModule,
    MediaModule,
    ProfileModule,
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
