import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { User } from '../../user/entities/user.entity';
import { File } from 'src/apis/media/entities/file.entity';
import autopopulateSoftDelete from 'src/utils/mongoose-plugins/autopopulate-soft-delete';

export type ProfileDocument = Profile & Document;

@Schema({})
export class Profile {
  @Prop({
    type: String,
    required: false,
  })
  firstName: string;

  @Prop({
    type: String,
    required: false,
  })
  lastName: string;

  @Prop({
    type: String,
    required: false,
  })
  phone: string;

  @Prop({
    type: Date,
    required: false,
  })
  birthday: Date;

  @Prop({
    type: Types.ObjectId,
    required: false,
    ref: 'File',
    refClass: File,
  })
  avatar: Types.ObjectId;

  @Prop({
    type: Types.ObjectId,
    required: true,
    ref: 'User',
    refClass: User,
  })
  user: Types.ObjectId;
}

export const ProfileSchema = SchemaFactory.createForClass(Profile);
ProfileSchema.plugin(autopopulateSoftDelete);
