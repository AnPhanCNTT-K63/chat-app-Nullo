import { BadRequestException, Injectable } from '@nestjs/common';
import * as bcrypt from 'bcrypt';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model, Types } from 'mongoose';
import { User } from './entities/user.entity';
import { CreateUserDto } from './dto/create-user.dto';
import { Profile } from '../profile/entities/profile.entity';
import { UpdateAccountDto } from './dto/update-account.dto';
import { UserPayload } from 'src/base/models/user-payload.model';

@Injectable()
export class UserService {
  constructor(
    @InjectModel(User.name)
    private readonly userModel: Model<User>,
    @InjectModel(Profile.name)
    private readonly profileModel: Model<Profile>,
  ) {}

  async getAll(filter: FilterQuery<User> = {}) {
    return await this.userModel
      .find(filter)
      .populate(this.getPopulateOptions())
      .exec();
  }

  async getOne(filter: FilterQuery<User>) {
    try {
      return await this.userModel
        .findOne(filter)
        .populate(this.getPopulateOptions());
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  async creatOne(userDto: CreateUserDto) {
    try {
      var newUser = await this.userModel.create(userDto);

      var profile = new Profile();
      profile.user = newUser._id;
      const newProfile = await this.profileModel.create(profile);
      newUser.profile = newProfile._id;
      newProfile.save();

      newUser.save();
      return {
        message: 'Create success',
      };
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  async updateAccount(
    userPayload: UserPayload,
    updateDto: Partial<UpdateAccountDto>,
  ) {
    try {
      if (updateDto.password) {
        updateDto.password = await bcrypt.hash(updateDto.password, 10);
      }

      const existingUser = await this.userModel.findByIdAndUpdate(
        new Types.ObjectId(userPayload._id),
        { $set: updateDto },
        { new: true },
      );

      return existingUser;
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  private getPopulateOptions() {
    return {
      path: 'profile',
      populate: ['avatar'],
    };
  }
}
