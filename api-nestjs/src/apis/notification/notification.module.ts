import { Module } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { UsersModule } from '../user/user.module';
import { MediaModule } from '../media/media.module';

@Module({
  imports: [UsersModule, MediaModule],
  controllers: [],
  providers: [NotificationService],
  exports: [NotificationService],
})
export class NotificationModule {}
