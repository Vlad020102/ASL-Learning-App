export class CreateUserDto {
  username: string;
  password: string;
  email: string;
  source?: string;
  dailyGoal?: number;
  learningReason?: string;
  referralCode?: string;
}
