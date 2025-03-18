import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { FilterQuery, Model } from 'mongoose';
import { User, UserDocument } from './entities/user.entity';
import { FilterDto } from './dto/filter.dto';
import { CreateUserDto } from './dto/create-user.dto';
import { Profile } from '../profile/entities/profile.entity';

@Injectable()
export class UserService {
  constructor(
    @InjectModel(User.name)
    private readonly userModel: Model<User>,
    @InjectModel(Profile.name)
    private readonly profileModel: Model<Profile>,
  ) {}

  getAll(filterQuery?: FilterDto) {
    const filter: FilterQuery<User> = this.buildFilter(filterQuery);

    return this.userModel.find(filter);
  }

  getOne(filter: FilterQuery<User>) {
    try {
      return this.userModel.findOne(filter);
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

  private buildFilter(filterQuery?: FilterDto): FilterQuery<User> {
    if (!filterQuery || Object.keys(filterQuery).length === 0) {
      return {};
    }

    const filter: FilterQuery<User> = {};

    if (filterQuery.username) {
      filter.username = { $regex: filterQuery.username, $options: 'i' };
    }

    return filter;
  }
}
