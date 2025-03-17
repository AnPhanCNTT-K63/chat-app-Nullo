import { Types } from 'mongoose';

export class UserPayload {
  _id: Types.ObjectId;
  username: string;
  email: string;
}
