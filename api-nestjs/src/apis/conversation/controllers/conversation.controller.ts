import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ConversationService } from '../conversation.service';
import { CreateConversationDto } from '../dto/create-conversation.dto';

@Controller('conversation')
export class ConversationController {
  constructor(private conversationService: ConversationService) {}

  @Get('/')
  getALl() {
    return this.conversationService.getAll();
  }

  @Get('/:id')
  getOne(@Param('id') id: string) {
    return this.conversationService.getByUserId(id);
  }

  @Post('/create')
  createOne(@Body() dto: CreateConversationDto) {
    return this.conversationService.createOne(dto);
  }
}
