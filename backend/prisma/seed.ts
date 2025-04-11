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
    icon: 'figure.step.training',
    description: 'Reach level 1 in your learning journey',
  },
  {
    name: 'Getting Started',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Level,
    icon: 'flag.pattern.checkered',
    description: 'Reach level 5 in your learning journey',
  },
  {
    name: 'Steady Progress',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Level,
    icon: 'figure.run.treadmill',
    description: 'Reach level 10 in your learning journey',
  },
  {
    name: 'Dedicated Learner',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Level,
    icon: 'graduationcap',
    description: 'Reach level 25 in your learning journey',
  },
  {
    name: 'Master Signer',
    rarity: BadgeRarity.Gold,
    type: BadgeType.Level,
    icon: 'medal.fill',
    description: 'Reach level 50 in your learning journey',
  },
  {
    name: 'First Question',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Question,
    icon: '1.circle',
    description: 'Answer your first question correctly',
  },
  {
    name: 'Curious Mind',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Question,
    icon: 'brain.head.profile',
    description: 'Answer 50 questions correctly',
  },
  {
    name: 'Knowledge Seeker',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Question,
    icon: 'sparkle.magnifyingglass',
    description: 'Answer 100 questions correctly',
  },
  {
    name: 'Expert Answerer',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Question,
    icon: 'medal.star',
    description: 'Answer 250 questions correctly',
  },
  {
    name: 'Sign Language Master',
    rarity: BadgeRarity.Gold,
    type: BadgeType.Question,
    icon: 'crown.fill',
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
  {
    type: QuizType.Matching,
    title: 'Basic Signs Matching',
    pairs: [
      {
        text: "Hello",
        signGif: "how-are-you",
        matchIndex: 0,
      },
      {
        text: "Goodbye",
        signGif: "how-are-you",
        matchIndex: 1,
      },
      {
        text: "Thank you",
        signGif: "how-are-you",
        matchIndex: 2,
      }
    ]
  }
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

async function createQuizes() {
  for (const quiz of quizData) {
    const createdQuiz = await prisma.quiz.create({
      data: {
        type: quiz.type,
        title: quiz.title,
      },
    });

    if (quiz.type === QuizType.Bubbles) {
      for (const sign of quiz.signs) {
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
    }

    else if (quiz.type === QuizType.Matching) {
      for (const pair of quiz.pairs) {
        const createdPair = await prisma.pair.create({
          data: {
            text: pair.text,
            signGif: pair.signGif,
          }
        });

        await prisma.quizPair.create({
          data: {
            quiz: {
              connect: {
                id: createdQuiz.id
              }
            },
            pair: {
              connect: {
                id: createdPair.id
              }
            },
            matchIndex: pair.matchIndex,
          }
        });
      }
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