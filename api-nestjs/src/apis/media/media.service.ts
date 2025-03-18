import { BadRequestException, Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { appSettings } from 'src/configs/app-settings';
import { IUploadedMulterFile, S3Service } from 'src/pakages/s3/s3.service';
import { File } from './entities/file.entity';
import { UserPayload } from 'src/base/models/user-payload.model';

@Injectable()
export class MediaService {
  constructor(
    @InjectModel(File.name)
    private readonly fileModel: Model<File>,
    private readonly s3Service: S3Service,
  ) {}

  async createFile(
    file: IUploadedMulterFile,
    user: UserPayload,
    folder: string = appSettings.s3.folder,
  ) {
    const uploadedFile = await this.s3Service.uploadPublicFile(file, folder);

    if (!uploadedFile) {
      throw new BadRequestException('Can not upload image');
    }

    const { fieldName, originalname, mimetype, size } = file;

    const result = await this.fileModel.create({
      filename: fieldName,
      name: originalname,
      alt: originalname,
      mime: mimetype,
      size,
      filePath: appSettings.s3.distribution + uploadedFile.key,
      folder,
      createdBy: user._id,
    });

    if (!result) return new BadRequestException("Can't create file");

    return result;
  }

  async deleteMedia(fileName: string) {
    const uploadedAvatar = await this.s3Service.deletePublicFile(
      fileName,
      'marketplace',
    );
    if (!uploadedAvatar) throw new BadRequestException('Can not delte image');

    return uploadedAvatar;
  }
}
