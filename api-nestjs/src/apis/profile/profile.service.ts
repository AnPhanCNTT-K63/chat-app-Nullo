import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Profile } from './entities/profile.entity';
import { FilterQuery, Model, Types } from 'mongoose';
import { UserPayload } from 'src/base/models/user-payload.model';
import { IUploadedMulterFile } from 'src/pakages/s3/s3.service';
import { MediaService } from '../media/media.service';
import { CreateProfileDto } from './dto/create-profile.dto';
@Injectable()
export class ProfileService {
  constructor(
    @InjectModel(Profile.name)
    private readonly profileModel: Model<Profile>,
    private readonly mediaService: MediaService,
  ) {}

  async updateOne(
    userPayload: UserPayload,
    profileDto: Partial<CreateProfileDto>,
  ) {
    try {
      const updatedProfile = await this.profileModel.findOneAndUpdate(
        { user: new Types.ObjectId(userPayload._id) },
        { $set: profileDto },
        { new: true },
      );
      if (!updatedProfile) throw new BadRequestException('Profile not found');

      updatedProfile.save();

      return updatedProfile;
    } catch (error) {
      throw new BadRequestException(error);
    }
  }

  async uploadAvatar(avatar: IUploadedMulterFile, user: UserPayload) {
    try {
      if (!avatar) return new BadRequestException('Avatar null');

      const newAvatarFile = await this.mediaService.createFile(
        avatar,
        user,
        'avatars',
      );

      if (newAvatarFile instanceof BadRequestException) throw newAvatarFile;

      const existingProfile = await this.profileModel.findOne({
        user: new Types.ObjectId(user._id),
      });

      newAvatarFile.createdBy = new Types.ObjectId(user._id);

      await newAvatarFile.save();

      if (!existingProfile) {
        throw new BadRequestException('Profile not found');
      }

      existingProfile.avatar = newAvatarFile._id;

      await existingProfile.save();
    } catch (error) {
      throw new BadRequestException(error);
    }
  }
}
