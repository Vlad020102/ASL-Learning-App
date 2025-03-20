import { 
  pgTable, 
  serial, 
  text, 
  timestamp, 
  integer, 
  pgEnum 
} from 'drizzle-orm/pg-core';

export const badgeRarityEnum = pgEnum('badge_rarity', ['Bronze', 'Silver', 'Gold']);
export const badgeTypeEnum = pgEnum('badge_type', ['Level', 'Question']);
export const quizTypeEnum = pgEnum('quiz_type', ['Bubbles', 'Matching', 'VideoText', 'VideoAudio', 'AlphabetStreak']);
export const difficultyEnum = pgEnum('difficulty', ['Hard', 'Easy', 'Moderate']);

// Define tables
export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  username: text('username').notNull().unique(),
  password: text('password').notNull(),
  email: text('email').notNull().unique(),
  source: text('source').notNull().default('Google Search'),
  dailyGoal: text('daily_goal').notNull().default('5'),
  learningReason: text('learning_reason').notNull().default('For work or school'),
  level: integer('level').notNull().default(1),
  questions_answered: integer('questions_answered').notNull().default(0),
  createdAt: timestamp('created_at').notNull().defaultNow(),
  updatedAt: timestamp('updated_at').notNull().defaultNow(),
});

export const badges = pgTable('badges', {
  id: serial('id').primaryKey(),
  name: text('name').notNull(),
  rarity: badgeRarityEnum('rarity').notNull(),
  type: badgeTypeEnum('type').notNull(),
  icon: text('icon').notNull(),
  description: text('description').notNull(),
});

export const userBadges = pgTable('user_badges', {
  id: serial('id').primaryKey(),
  user_id: integer('user_id').notNull().references(() => users.id),
  badge_id: integer('badge_id').notNull().references(() => badges.id),
});

export const lessons = pgTable('lessons', {
  id: serial('id').primaryKey(),
});

export const signs = pgTable('signs', {
  id: serial('id').primaryKey(),
  difficulty: difficultyEnum('difficulty').notNull(),
  sign_url: text('sign_url').notNull(),
  text: text('text').notNull(),
});

export const quizzes = pgTable('quizzes', {
  id: serial('id').primaryKey(),
  type: quizTypeEnum('type').notNull(),
  sign_id: integer('sign_id').notNull().references(() => signs.id),
});

export const phrases = pgTable('phrases', {
  id: serial('id').primaryKey(),
  difficulty: difficultyEnum('difficulty').notNull(),
});

export const phrasesSign = pgTable('phrases_sign', {
  id: serial('id').primaryKey(),
  sign_id: integer('sign_id').references(() => signs.id),
  phrase_id: integer('phrase_id').references(() => phrases.id),
  order: integer('order'),
});