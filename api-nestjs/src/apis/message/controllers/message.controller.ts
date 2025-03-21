import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { MessageService } from '../message.service';
import { CreateMessageDto } from '../dto/create-message.dto';

@Controller('message')
export class MessageController {
  constructor(private readonly messageService: MessageService) {}

  @Post('/create')
  async createMessage(@Body() dto: CreateMessageDto) {
    return await this.messageService.createOne(dto);
  }

  @Get('/:conversation_id')
  async getByConversation(@Param('conversation_id') id: string) {
    return await this.messageService.getByConvId(id);
  }
}
