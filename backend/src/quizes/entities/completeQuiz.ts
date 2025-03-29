import { QuizStatus } from "@prisma/client";
import { IsEnum, IsNumber, IsString } from "class-validator";

export class CompleteQuizDTO {
    @IsNumber()
    quizId: number;

    @IsEnum(QuizStatus)
    status: QuizStatus;

    @IsString()
    score: string;

    @IsNumber()
    livesRemaining: number;
}
