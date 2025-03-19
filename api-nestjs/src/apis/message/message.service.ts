import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model, Types } from 'mongoose';
import { Message } from './entities/message.entity';
import { CreateMessageDto } from './dto/create-message.dto';

@Injectable()
export class MessageService {
  constructor(
    @InjectModel(Message.name) private readonly messageModel: Model<Message>,
  ) {}

  createOne(dto: CreateMessageDto) {
    try {
      var message = this.messageModel.create(dto);

      if (!message) throw new BadRequestException("Can't create");

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
