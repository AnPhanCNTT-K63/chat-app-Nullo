import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { MessageService } from '../message.service';
import { CreateMessageDto } from '../dto/create-message.dto';

@Controller('message')
export class MessageController {
  constructor(private readonly messageService: MessageService) {}

  @Post('/create')
  createMessage(@Body() dto: CreateMessageDto) {
    return this.messageService.createOne(dto);
  }

  @Get('/:id')
  getByConversation(@Param('id') id: string) {
    return this.messageService.getByConvId(id);
  }
}
