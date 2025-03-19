import { Module } from '@nestjs/common';
import { ChatGateway } from './chat.gateway';
import { MongooseModule } from '@nestjs/mongoose';
import {
  Conversation,
  ConversationSchema,
} from './entities/conversation.entity';
import { ConversationController } from './controllers/conversation.controller';
import { ConversationService } from './conversation.service';

@Module({
  imports: [
    MongooseModule.forFeature([
      { name: Conversation.name, schema: ConversationSchema },
    ]),
  ],
  controllers: [ConversationController],
  providers: [ChatGateway, ConversationService],
  exports: [ChatGateway, ConversationService],
})
export class ConversationModule {}
