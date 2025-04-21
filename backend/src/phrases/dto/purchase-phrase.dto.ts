import { PhraseStatus } from "@prisma/client";
import { IsEnum, IsNumber } from "class-validator";

export class PurchasePhraseDto {
    @IsEnum(PhraseStatus)
    status: string;

    @IsNumber()
    price: number;
}
