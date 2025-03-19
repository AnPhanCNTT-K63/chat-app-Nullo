import { ApiProperty } from '@nestjs/swagger';
import { IsOptional, IsString } from 'class-validator';

export class UpdateAccountDto {
  @ApiProperty({
    type: String,
  })
  @IsOptional()
  @IsString()
  email: string;

  @ApiProperty({
    type: String,
  })
  @IsOptional()
  @IsString()
  password: string;

  @ApiProperty({
    type: String,
  })
  @IsOptional()
  @IsString()
  username: string;
}
