import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { UserService } from '../user/user.service';
import { Types } from 'mongoose';
import * as path from 'path';
import { appSettings } from 'src/configs/app-settings';

@Injectable()
export class NotificationService {
  constructor(private readonly userService: UserService) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: appSettings.firebase.projectId,
        privateKey: appSettings.firebase.key,
        clientEmail: appSettings.firebase.clientEmail,
      }),
    });
  }

  async sendPushNotification(
    receiverId: Types.ObjectId,
    message: string,
    conversationId: Types.ObjectId,
  ) {
    const user = await this.userService.getOne({ _id: receiverId });
    if (!user || !user.fcmToken) return;

    const payload = {
      notification: {
        title: 'New Message!',
        body: message,
      },
      token: user.fcmToken,
    };

    try {
      await admin.messaging().send(payload);
      console.log('Notification sent successfully');
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  }
}
