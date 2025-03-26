import { ApiProperty } from '@nestjs/swagger';
import { Transform } from 'class-transformer';
import { IsNotEmpty, IsString } from 'class-validator';
import { Types } from 'mongoose';
import { convertStringToObjectId } from 'src/utils/helper';

export class CreateMessageDto {
  @ApiProperty({
    type: String,
    required: true,
  })
  @IsNotEmpty()
  @IsString()
  text: string;

  @ApiProperty({
    type: String,
    required: true,
  })
  @IsNotEmpty()
  @Transform(({ value }) => convertStringToObjectId(value))
  sender: Types.ObjectId;

  @ApiProperty({
    type: String,
    required: true,
  })
  @IsNotEmpty()
  @Transform(({ value }) => convertStringToObjectId(value))
  receiver: Types.ObjectId;

  @ApiProperty({
    type: String,
    required: true,
  })
  @IsNotEmpty()
  @Transform(({ value }) => convertStringToObjectId(value))
  conversation: Types.ObjectId;
}
