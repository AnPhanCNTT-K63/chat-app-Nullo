import { Controller } from '@nestjs/common';
import { ProfileService } from '../profile.service';

@Controller('profile')
export class ProfileController {
  constructor(private profileService: ProfileService) {}
}
