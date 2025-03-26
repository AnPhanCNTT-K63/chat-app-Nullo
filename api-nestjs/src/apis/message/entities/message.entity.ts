import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Types } from 'mongoose';
import { Conversation } from 'src/apis/conversation/entities/conversation.entity';
import { User } from 'src/apis/user/entities/user.entity';
import autopopulateSoftDelete from 'src/utils/mongoose-plugins/autopopulate-soft-delete';

export type MessageDocument = Message & Document;

@Schema({
  timestamps: true,
})
export class Message {
  @Prop({
    type: String,
  })
  text: string;

  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    refClass: User,
    required: true,
  })
  sender: Types.ObjectId;

  @Prop({
    type: Types.ObjectId,
    ref: 'User',
    refClass: User,
    required: true,
  })
  receiver: Types.ObjectId;

  @Prop({
    type: Types.ObjectId,
    ref: 'Conversation',
    refClass: Conversation,
    required: true,
  })
  conversation: Types.ObjectId;
}

export const MessageSchema = SchemaFactory.createForClass(Message);
MessageSchema.plugin(autopopulateSoftDelete);
