import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { CreateConversationDto } from './dto/create-conversation.dto';
import { Conversation } from './entities/conversation.entity';

@Injectable()
export class ConversationService {
  constructor(
    @InjectModel(Conversation.name)
    private readonly conversationModel: Model<Conversation>,
  ) {}

  async getAll() {
    try {
      return await this.conversationModel.find().exec();
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  async createOne(dto: CreateConversationDto) {
    try {
      const existingConversation = await this.conversationModel.findOne({
        members: { $all: [dto.senderId, dto.receiverId] },
      });

      if (existingConversation) return existingConversation;

      return await this.conversationModel.create({
        members: [dto.senderId, dto.receiverId],
      });
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  async getByUserId(id: string) {
    try {
      return await this.conversationModel
        .find({
          members: { $in: [id] },
        })
        .exec();
    } catch (error) {
      throw new BadRequestException(error);
    }
  }
}
