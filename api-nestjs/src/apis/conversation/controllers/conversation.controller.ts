import { Body, Controller, Get, Param, Post } from '@nestjs/common';
import { ConversationService } from '../conversation.service';
import { CreateConversationDto } from '../dto/create-conversation.dto';

@Controller('conversation')
export class ConversationController {
  constructor(private conversationService: ConversationService) {}

  @Get('/')
  async getALl() {
    return await this.conversationService.getAll();
  }

  @Get('/:id')
  async getOne(@Param('id') id: string) {
    return await this.conversationService.getByUserId(id);
  }

  @Post('/create')
  async createOne(@Body() dto: CreateConversationDto) {
    return await this.conversationService.createOne(dto);
  }
}
