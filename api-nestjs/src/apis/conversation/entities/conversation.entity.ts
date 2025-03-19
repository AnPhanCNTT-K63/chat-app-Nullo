import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import autopopulateSoftDelete from 'src/utils/mongoose-plugins/autopopulate-soft-delete';

export type ConversationDocument = Conversation & Document;

@Schema({
  timestamps: true,
})
export class Conversation {
  @Prop({
    type: Array,
  })
  members: Array<string>;
}

export const ConversationSchema = SchemaFactory.createForClass(Conversation);
ConversationSchema.plugin(autopopulateSoftDelete);
