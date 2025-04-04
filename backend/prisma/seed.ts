import { Difficulty, PrismaClient, QuizType } from '@prisma/client';
import { BadgeRarity, BadgeType } from '@prisma/client';
import { sign } from 'crypto';
import { connect } from 'http2';

const prisma = new PrismaClient();

const badgeData = [
  {
    name: 'First Steps',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Level,
    icon: 'level_bronze_1',
    description: 'Reach level 1 in your learning journey',
  },
  {
    name: 'Getting Started',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Level,
    icon: 'level_bronze_5',
    description: 'Reach level 5 in your learning journey',
  },
  {
    name: 'Steady Progress',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Level,
    icon: 'level_silver_10',
    description: 'Reach level 10 in your learning journey',
  },
  {
    name: 'Dedicated Learner',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Level,
    icon: 'level_silver_25',
    description: 'Reach level 25 in your learning journey',
  },
  {
    name: 'Master Signer',
    rarity: BadgeRarity.Gold,
    type: BadgeType.Level,
    icon: 'level_gold_50',
    description: 'Reach level 50 in your learning journey',
  },
  {
    name: 'First Question',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Question,
    icon: 'question_bronze_1',
    description: 'Answer your first question correctly',
  },
  {
    name: 'Curious Mind',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Question,
    icon: 'question_bronze_50',
    description: 'Answer 50 questions correctly',
  },
  {
    name: 'Knowledge Seeker',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Question,
    icon: 'question_silver_100',
    description: 'Answer 100 questions correctly',
  },
  {
    name: 'Expert Answerer',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Question,
    icon: 'question_silver_250',
    description: 'Answer 250 questions correctly',
  },
  {
    name: 'Sign Language Master',
    rarity: BadgeRarity.Gold,
    type: BadgeType.Question,
    icon: 'question_gold_500',
    description: 'Answer 500 questions correctly',
  },
];

const quizData = [
  {
    type: QuizType.Bubbles,
    title: 'Basic Signs',
    signs: [
      {
        difficulty: Difficulty.Easy,
        text: "Hello",
        s3Url: "url",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        text: "Goodbye",
        s3Url: "url",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        text: "Thank you",
        s3Url: "url",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        text: "Please",
        s3Url: "url",
        options: "Hello, Goodbye, Thank you, Please"
      },
    ],
  },
  {
    type: QuizType.Bubbles,
    title: 'Advanced Signs',
    signs: [
      {
        difficulty: Difficulty.Moderate,
        text: "Good morning",
        s3Url: "url",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        text: "Good night",
        s3Url: "url",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        text: "Good afternoon",
        s3Url: "url",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        text: "Good evening",
        s3Url: "url",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
    ],
  },
  {
    type: QuizType.Bubbles,
    title: 'Expert Signs',
    signs: [
      {
        difficulty: Difficulty.Hard,
        text: "How are you?",
        s3Url: "url",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        text: "What is your name?",
        s3Url: "url",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        text: "Where are you from?",
        s3Url: "url",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        text: "What do you do?",
        s3Url: "url",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
    ],
  },
]

async function createBadges() {
  for (const badge of badgeData) {
    const createdBadge = await prisma.badge.create({
      data: badge,
    });
    console.log(`Created badge with ID: ${createdBadge.id}`);
  }
  
  console.log('Seeding badges completed successfully');
}

async function createQuizes(){
  for(const quiz of quizData){
    const createdQuiz = await prisma.quiz.create({
      data: {
        type: quiz.type,
        title: quiz.title,
      },
    });

    console.log(createdQuiz.id)
    for(const sign of quiz.signs){
      const createdSign = await prisma.sign.create({
        data: {
          difficulty: sign.difficulty,
          text: sign.text,
          s3Url: sign.s3Url,
          options: sign.options,
        }
      });

      await prisma.quizSigns.create({
        data: {
          quiz: {
            connect: {
              id: createdQuiz.id
            } 
          },
          sign: {
            connect: {
              id: createdSign.id
            }
          }
        }
      });
    }
    console.log(`Created quiz with ID: ${createdQuiz.id}`);
  }
}

async function main() {
  console.log('Start seeding badges...');
  
  await createBadges();
  await createQuizes();
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });