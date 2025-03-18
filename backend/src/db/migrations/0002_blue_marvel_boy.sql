ALTER TABLE "users" ADD COLUMN "source" text DEFAULT 'Google Search' NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "daily_goal" text DEFAULT '5' NOT NULL;--> statement-breakpoint
ALTER TABLE "users" ADD COLUMN "learning_reason" text DEFAULT 'For work or school' NOT NULL;