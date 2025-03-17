import { Controller, Get, Param } from '@nestjs/common';
import { UserService } from '../user.service';
import { Types } from 'mongoose';

@Controller('users')
export class UserController {
  constructor(private readonly usersService: UserService) {}

  @Get()
  async getAllUsers() {
    return this.usersService.getAll();
  }

  @Get(':id')
  async getUserById(@Param('id') id: string) {
    return this.usersService.getOne({ _id: new Types.ObjectId(id) });
  }
}
