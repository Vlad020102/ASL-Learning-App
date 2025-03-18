import {
  IsEmail,
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  ValidateIf,
} from 'class-validator';

export class RegisterUserDto {
    @IsNotEmpty({ message: 'Either username or email must be provided' })
    @IsString()
    @IsEmail()
    email: string;

    @IsNotEmpty({ message: 'Password is required' })
    @IsString()
    username: string;

    @IsNotEmpty({ message: 'Password is required' })
    @IsString()
    password: string;

    @IsOptional()
    @IsString()
    source: string;

    @IsOptional()
    @IsNumber()
    dailyGoal: number;

    @IsOptional()
    @IsString()
    learningReason: string;
}
