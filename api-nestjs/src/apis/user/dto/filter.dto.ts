import { ApiProperty } from '@nestjs/swagger';
import { IsEmail, IsOptional, IsString } from 'class-validator';

export class FilterDto {
  @ApiProperty({
    type: String,
    required: false,
  })
  @IsOptional()
  @IsString()
  username: string;

  @ApiProperty({
    type: String,
    required: false,
  })
  @IsOptional()
  @IsEmail()
  email: string;
}
