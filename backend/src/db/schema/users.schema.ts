import { pgTable, serial, timestamp, text } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  username: text('username').notNull().unique(),
  password: text('password').notNull(),
  email: text('email').notNull().unique(),
  source: text('source').notNull().default('Google Search'),
  dailyGoal: text('daily_goal').notNull().default('5'),
  learningReason: text('learning_reason').notNull().default('For work or school'),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});
