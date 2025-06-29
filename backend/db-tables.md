# Core Database Tables

The ASL Learning App database consists of several core tables that store the fundamental entities of the application. Below is a brief description of each table's purpose:

## users
Stores user account information including credentials, learning progress metrics, and gamification data. This table tracks a user's level, streak count, virtual currency balance, and learning preferences.

## signs
Contains individual ASL signs with their visual representations, difficulty levels, and explanatory metadata. Each sign is a fundamental learning unit that can be included in quizzes and phrases.

## phrases
Stores complete ASL phrases or sentences that users can learn. Each phrase has associated difficulty, meaning, and can be purchased by users using virtual currency. Phrases are composed of multiple individual signs.

## badges
Represents achievement rewards that users can earn through learning activities. Badges have different rarities and types, encouraging users to progress through the application.

## quizzes
Contains different types of learning assessments (e.g., Bubbles, Matching, AlphabetStreak) that test users' knowledge of ASL. Quizzes incorporate signs or pairs and track user completion status.

## pairs
Stores matching pairs used in quizzes, typically containing an ASL sign and its textual representation that users need to match together.

## streak_freezes
Tracks instances where users have purchased streak freezes to maintain their daily learning streak even when missing a day of practice.

## extras
Contains supplementary learning materials such as articles, podcasts, videos, and events related to ASL and Deaf culture to expand users' knowledge beyond direct practice.

Each of these core tables is extended through intermediate junction tables to represent many-to-many relationships, creating a comprehensive learning ecosystem for ASL.
