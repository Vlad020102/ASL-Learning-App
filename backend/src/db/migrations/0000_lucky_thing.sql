CREATE TYPE "public"."badge_rarity" AS ENUM('Bronze', 'Silver', 'Gold');--> statement-breakpoint
CREATE TYPE "public"."badge_type" AS ENUM('Level', 'Question');--> statement-breakpoint
CREATE TYPE "public"."quiz_type" AS ENUM('Bubbles', 'Matching', 'VideoText', 'VideoAudio', 'AlphabetStreak');--> statement-breakpoint
CREATE TYPE "public"."sign_difficulty" AS ENUM('Hard', 'Easy', 'Moderate');--> statement-breakpoint
CREATE TABLE "badges" (
	"id" serial PRIMARY KEY NOT NULL,
	"name" text NOT NULL,
	"rarity" "badge_rarity" NOT NULL,
	"type" "badge_type" NOT NULL,
	"icon" text NOT NULL,
	"description" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "lessons" (
	"id" serial PRIMARY KEY NOT NULL
);
--> statement-breakpoint
CREATE TABLE "phrases" (
	"id" serial PRIMARY KEY NOT NULL,
	"natural_text" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "phrases_sign" (
	"id" serial PRIMARY KEY NOT NULL,
	"sign_id" integer,
	"phrase_id" integer,
	"order" integer
);
--> statement-breakpoint
CREATE TABLE "quizzes" (
	"id" serial PRIMARY KEY NOT NULL,
	"type" "quiz_type" NOT NULL,
	"sign_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "signs" (
	"id" serial PRIMARY KEY NOT NULL,
	"difficulty" "sign_difficulty" NOT NULL,
	"sign_url" text NOT NULL,
	"text" text NOT NULL
);
--> statement-breakpoint
CREATE TABLE "user_badges" (
	"id" serial PRIMARY KEY NOT NULL,
	"user_id" integer NOT NULL,
	"badge_id" integer NOT NULL
);
--> statement-breakpoint
CREATE TABLE "users" (
	"id" serial PRIMARY KEY NOT NULL,
	"username" text NOT NULL,
	"password" text NOT NULL,
	"email" text NOT NULL,
	"source" text DEFAULT 'Google Search' NOT NULL,
	"daily_goal" text DEFAULT '5' NOT NULL,
	"learning_reason" text DEFAULT 'For work or school' NOT NULL,
	"level" integer DEFAULT 1 NOT NULL,
	"questions_answered" integer DEFAULT 0 NOT NULL,
	"created_at" timestamp DEFAULT now() NOT NULL,
	"updated_at" timestamp DEFAULT now() NOT NULL,
	CONSTRAINT "users_username_unique" UNIQUE("username"),
	CONSTRAINT "users_email_unique" UNIQUE("email")
);
--> statement-breakpoint
ALTER TABLE "phrases_sign" ADD CONSTRAINT "phrases_sign_sign_id_signs_id_fk" FOREIGN KEY ("sign_id") REFERENCES "public"."signs"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "phrases_sign" ADD CONSTRAINT "phrases_sign_phrase_id_phrases_id_fk" FOREIGN KEY ("phrase_id") REFERENCES "public"."phrases"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "quizzes" ADD CONSTRAINT "quizzes_sign_id_signs_id_fk" FOREIGN KEY ("sign_id") REFERENCES "public"."signs"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_badges" ADD CONSTRAINT "user_badges_user_id_users_id_fk" FOREIGN KEY ("user_id") REFERENCES "public"."users"("id") ON DELETE no action ON UPDATE no action;--> statement-breakpoint
ALTER TABLE "user_badges" ADD CONSTRAINT "user_badges_badge_id_badges_id_fk" FOREIGN KEY ("badge_id") REFERENCES "public"."badges"("id") ON DELETE no action ON UPDATE no action;