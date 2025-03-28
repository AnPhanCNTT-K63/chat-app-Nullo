import { Injectable } from '@nestjs/common';
import * as admin from 'firebase-admin';
import { UserService } from '../user/user.service';
import { Types } from 'mongoose';
import { appSettings } from 'src/configs/app-settings';
import { MediaService } from '../media/media.service';

@Injectable()
export class NotificationService {
  constructor(
    private readonly userService: UserService,
    private readonly mediaService: MediaService,
  ) {
    admin.initializeApp({
      credential: admin.credential.cert({
        projectId: appSettings.firebase.projectId,
        privateKey:
          '-----BEGIN PRIVATE KEY-----\nMIIEvwIBADANBgkqhkiG9w0BAQEFAASCBKkwggSlAgEAAoIBAQC/CMH7t3ZOCbCB\nyB5U6DyCMXJCdR8LlXOG16wx2mK1dw4Cth1lC2EZijQ2ZRBf6csbyTAihiG4/JU+\nG0t31U8rZRjCWxmH9pCgws41WxMzHEn7X/cqWX2RWJEyYxN5cKmJwThquRxAM8zT\nNWzDSYi8CE4NZvtWH4a9Zda3N11zaq6uUE1ZA8hOgyvcF8RMyR0zw/XgxgsPSXis\n6swkFycWgv5SBgpGw+0TmQIoSPSn5boi01N5fWwb+w5LyLwrZeqWFLO3XW/Y+3d6\nM0sm9F/4Afy+ZjMQyaX/JOz1GP6XwdhgMC88uNRbYDm2zShNUrjcPu9J0Hbp6X6l\n0wjR/KGrAgMBAAECggEAEtom5pPi2W2sXQpmL+PhQMnnaDaNs0Ny7K4xAJR4JEdU\n+yCEwxl94hrY7ztHA+gbEqlmlimdf1dx1Pi1mGRVFUe7S0bZPKkw+aRv3CUaPnN+\nu49rYWMGeMcAQTQ00kmzeXQ3gJS2/IEAKCHAE3+YvlGlfj4Y9JVU4zD/IQKWNtL2\n5CscyIfzrmf/jqGHDjZGYTSo7L9yqJrxPmdxjTYMXpTbd1mD6A+Yh0zX3Jno1Hb/\nSxy02X9a7HOym6AVpcy//oRnpxrV4hRSwQAI539B3Gt2qeItfP71ogJEUZ0HdVtc\niEBIrGpCK5bB4awFKXEaIn53rMAhtXZ34fI8hGUyZQKBgQD50CTWDjx0DwnfTcb8\notPV8VKUfYcwZKlNzOiVXMgQyPrCoasjOeEvZKSDudEmBFjZ/61sqWR4MRKYL1gb\n6xRlv3bBM7LCk7iukT24VwgZyJNFzppc7EhTrjJISu4OcmCPLvoRHmet3GhzpMmD\n4N2WFdeUl6zSinZTDFGDmxVbpQKBgQDDw/I7R4D2dnd1vIZY9j2IWpEe1VPRGu/k\nhe5ih+nfFIEqcUfzwNj69hcF8crGXwAM66xTTO7CzabZ2KWyAjKc9AzzJbLAjPTa\neMpurA4GHSwN59Oemffn3DkRPoyBk6Tv1IlDhBstHL8m7n4oItLYLY0/dFa5ldlb\n1ZZmz1PHDwKBgQDRbGIFJSge76CKGGzxzBskpstg+p8Dvc+FDnwJAyAhmitGUTvk\nKxiRn6CfYX5pjYljMAmWJ6e3bwQ0mrQVq4yNA+atbwa0Qhy4E8CXMjbzTofQJLSZ\no+e6ZzV2D4Lkj5RNVMeE5GVshnL2R7Y8HZ4FvUfeJQ1X74Xkd1Y6qx9LlQKBgQC9\nt29Qs4LvVu9+Ui2AmWIYemyZDPQleY1yUbksE7s6TYy/rPil6QZeb47wW9q/U+Gg\no+Rk9fGNJ+/CvooVcLvMD1dda/NHV1MTRmwnxOXyVuMSttAGq//r2ygS5iMUkBkP\ns1Ey9RvBJFK7T/VCwDzE86AnFn/VarsynFMdX185UQKBgQCYd44JsNQT5ctUfs70\n69mu0Y0Hqyrx5FHUQYxk/9bFm4A4VyToV0Pc7x3IqIgP6CSYPLhkrLydDm3ShJQZ\nznFegYjaGlRyY32BgFkKjZP9gqoQQyzgA9F4AHRqs3L7Aagv6gl2OoxHdpKWJHyb\n3Y/8ze1oXLCo0QtbLPRPxHbpaA==\n-----END PRIVATE KEY-----\n',
        clientEmail: appSettings.firebase.clientEmail,
      }),
    });
  }

  async sendPushNotification(
    receiverId: Types.ObjectId,
    senderId: Types.ObjectId,
    message: string,
    conversationId: Types.ObjectId,
  ) {
    const receiver = await this.userService.getOne({ _id: receiverId });
    const sender = await this.userService.getOne({ _id: senderId });

    const image = (await this.mediaService.getImage(senderId)) ?? '';

    const title = sender?.username;

    if (!receiver || !receiver.fcmToken) return;

    const payload = {
      notification: {
        title: title,
        body: message,
      },

      data: {
        senderImage: JSON.stringify(image),
        sender: JSON.stringify(sender),
        receiver: JSON.stringify(receiver),
        conversationId: JSON.stringify(conversationId),
      },
      token: receiver.fcmToken,
    };

    try {
      await admin.messaging().send(payload);
    } catch (error) {
      console.error('Error sending notification:', error);
    }
  }
}
