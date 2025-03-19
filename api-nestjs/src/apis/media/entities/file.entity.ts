import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { User } from 'src/apis/user/entities/user.entity';
import autopopulateSoftDelete from 'src/utils/mongoose-plugins/autopopulate-soft-delete';

export type FileDocument = File & Document;

@Schema({
  timestamps: true,
})
export class File {
  @Prop({
    type: String,
  })
  filePath: string;

  @Prop({
    type: String,
  })
  name: string;

  @Prop({
    type: String,
  })
  filename: string;

  @Prop({ type: String })
  folder: string;

  @Prop({ type: String })
  note: string;

  @Prop({ type: String })
  mime: string;

  @Prop({ type: Number })
  size: number;

  @Prop({ type: String })
  alt: string;

  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    refClass: User,
  })
  createdBy: Types.ObjectId;
}

export const FileSchema = SchemaFactory.createForClass(File);
FileSchema.plugin(autopopulateSoftDelete);
