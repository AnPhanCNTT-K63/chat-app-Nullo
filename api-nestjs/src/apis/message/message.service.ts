import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Message } from './entities/message.entity';
import { CreateMessageDto } from './dto/create-message.dto';
import { NotificationService } from '../notification/notification.service';

@Injectable()
export class MessageService {
  constructor(
    @InjectModel(Message.name) private readonly messageModel: Model<Message>,
    private readonly notificationService: NotificationService,
  ) {}

  async createOne(dto: CreateMessageDto) {
    try {
      var message = await this.messageModel.create(dto);

      if (!message) throw new BadRequestException("Can't create");

      await this.notificationService.sendPushNotification(
        dto.receiver,
        dto.sender,
        dto.text,
        dto.conversation,
      );

      return message;
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  getByConvId(id: string) {
    try {
      return this.messageModel.find({ conversation: new Types.ObjectId(id) });
    } catch (error) {
      throw new BadRequestException(error);
    }
  }
}
