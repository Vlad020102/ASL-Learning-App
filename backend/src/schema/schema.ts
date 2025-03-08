import {
    pgTable,
    pgEnum,
    serial,
    timestamp,
    text,
    integer,
    primaryKey,
    boolean,
    uuid,
  } from 'drizzle-orm/pg-core';
  import { InferSelectModel } from 'drizzle-orm';
  
  export const posts = pgTable('posts', {
    id: serial('id').primaryKey(),
    authorId: integer('author_id')
      .notNull(),
    content: text('content'),
    mediaUrl: text('media_url'),
    createdAt: timestamp('created_at').notNull().defaultNow(),
    updatedAt: timestamp('updated_at').notNull().defaultNow(),
  });