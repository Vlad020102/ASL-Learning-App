ALTER TYPE "public"."sign_difficulty" RENAME TO "difficulty";--> statement-breakpoint
ALTER TABLE "phrases" RENAME COLUMN "natural_text" TO "difficulty";