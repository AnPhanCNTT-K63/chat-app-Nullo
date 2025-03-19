import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString } from 'class-validator';
import { Types } from 'mongoose';
import { convertStringToObjectId } from 'src/utils/helper';

export class CreateConversationDto {
  @ApiProperty({
    type: String,
    required: true,
  })
  @IsNotEmpty()
  @Transform(({ value }) => convertStringToObjectId(value))
  senderId: Types.ObjectId;

  @ApiProperty({
    type: String,
    required: true,
  })
  @IsNotEmpty()
  @Transform(({ value }) => convertStringToObjectId(value))
  receiverId: Types.ObjectId;
}
