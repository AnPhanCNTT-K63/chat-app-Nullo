import { Module } from '@nestjs/common';
import { MongooseModule } from '@nestjs/mongoose';
import { appSettings } from './configs/app-settings';
import { ConfigModule } from '@nestjs/config';

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
  ],
  controllers: [],
  providers: [],
})
export class AppModule {}
