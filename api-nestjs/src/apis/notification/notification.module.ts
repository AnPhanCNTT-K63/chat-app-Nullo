import { Module } from '@nestjs/common';
import { NotificationService } from './notification.service';
import { UsersModule } from '../user/user.module';

@Module({
  imports: [UsersModule],
  controllers: [],
  providers: [NotificationService],
  exports: [NotificationService],
})
export class NotificationModule {}
