import { Difficulty, PrismaClient, QuizType } from '@prisma/client';
import { BadgeRarity, BadgeType } from '@prisma/client';
import { title } from 'process';
import { start } from 'repl';

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
  },
  {
    type: QuizType.AlphabetStreak,
    title: 'Basic Alphabet Streak Quiz',
  }
]

const alphabet = [
  "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
  "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
  "U", "V", "W", "X", "Y", "Z"
]

async function createBadges() {
  for (let i = 0; i < badgeData.length; i++) {
    const badge = badgeData[i];
    try {
      const createdBadge = await prisma.badge.create({
        data: {
          id: i,
          ...badge
        }
      });
      console.log(`Created badge with ID: ${createdBadge.id}`)
    }
    catch (error) {
      console.error(`Error creating badge with ID: ${i}`, error);
    }
  }


  console.log('Seeding badges completed successfully');
}

async function createQuizes() {
  try {
    for (let i = 0; i < quizData.length; i++) {
      const quiz = quizData[i];

      if (quiz.type === QuizType.AlphabetStreak) {

        for (let l = 0; l < 5; l++) {
          const startIndex = l * 5;
          const letters = alphabet.slice(startIndex, startIndex + 5);
          if (startIndex == 20) {
            letters.push("Z");
          }
          try { 
            let createdQuiz = await prisma.quiz.create({
              data: {
                type: quiz.type,
                title: quiz.title + ` #${l + 1}`,
              }
            });
            for (const letter of letters) {
              const sign = await prisma.sign.create({
                data: {
                  text: letter,
                  s3Url: `alphabet/${letter.toLowerCase()}`,
                  difficulty: Difficulty.Easy
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
                      id: sign.id
                    }
                  }
                }
              });
            }
          } catch (error) {
            console.error(`Error creating alphabet streak signs for quiz ${quiz.title}:`, error);
          }
        }
        continue; 
      }
      try {
        const createdQuiz = await prisma.quiz.create({
          data: {
            id: i,
            type: quiz.type,
            title: quiz.title,
          },
        });


        if (quiz.type === QuizType.Bubbles) {
          for (let j = 0; j < quiz.signs.length; j++) {
            const sign = quiz.signs[j];
            const createdSign = await prisma.sign.create({
              data: {
                text: sign.text,
                s3Url: sign.s3Url,
                difficulty: sign.difficulty,
              }
            });
            try {
              await prisma.quizSigns.create({
                data: {
                  options: sign.options,
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
            } catch (error) {
              console.error(`Error creating sign ${j} for quiz ${i}:`, error);
            }
          }
        }

        else if (quiz.type === QuizType.Matching) {
          for (let k = 0; k < quiz.pairs.length; k++) {
            try {
              const pair = quiz.pairs[k];
              const createdPair = await prisma.pair.create({
                data: {
                  id: k,
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
            } catch (error) {
              console.error(`Error creating pair ${k} for quiz ${i}:`, error);
            }
          }
        }
        console.log(`Created quiz with ID: ${createdQuiz.id}`);
      } catch (error) {
        console.error(`Error creating quiz ${i}:`, error);
      }
    }
  } catch (error) {
    console.error('Error in createQuizes function:', error);
    throw error; // Re-throw the error to be caught by the main function
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