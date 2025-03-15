
import { IsEmail, IsNotEmpty, IsOptional, IsString, ValidateIf } from 'class-validator';

export class LoginUserDto {
  @IsNotEmpty({ message: 'Either username or email must be provided' })
  @IsString()
  emailOrUsername?: string;

  @IsNotEmpty({ message: 'Password is required' })
  @IsString()
  password: string;
}
