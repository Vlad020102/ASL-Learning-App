import { targetModulesByContainer } from '@nestjs/core/router/router-module';
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
    icon: 'figure.step.training',
    description: 'Reach level 1 in your learning journey',
    target: 10,
  },
  {
    name: 'Getting Started',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Level,
    icon: 'flag.pattern.checkered',
    description: 'Reach level 5 in your learning journey',
    target: 50,
  },
  {
    name: 'Steady Progress',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Level,
    icon: 'figure.run.treadmill',
    description: 'Reach level 10 in your learning journey',
    target: 100,
  },
  {
    name: 'Dedicated Learner',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Level,
    icon: 'graduationcap',
    description: 'Reach level 25 in your learning journey',
    target: 250,
  },
  {
    name: 'Master Signer',
    rarity: BadgeRarity.Gold,
    type: BadgeType.Level,
    icon: 'medal.fill',
    description: 'Reach level 50 in your learning journey',
    target: 500,
  },
  {
    name: 'First Question',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Question,
    icon: '1.circle',
    description: 'Answer your first question correctly',
    target: 1
  },
  {
    name: 'Curious Mind',
    rarity: BadgeRarity.Bronze,
    type: BadgeType.Question,
    icon: 'brain.head.profile',
    description: 'Answer 50 questions correctly',
    target: 50
  },
  {
    name: 'Knowledge Seeker',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Question,
    icon: 'sparkle.magnifyingglass',
    description: 'Answer 100 questions correctly',
    target: 100
  },
  {
    name: 'Expert Answerer',
    rarity: BadgeRarity.Silver,
    type: BadgeType.Question,
    icon: 'medal.star',
    description: 'Answer 250 questions correctly',
    target: 250
  },
  {
    name: 'Sign Language Master',
    rarity: BadgeRarity.Gold,
    type: BadgeType.Question,
    icon: 'crown.fill',
    description: 'Answer 500 questions correctly',
    target: 500
  },
];

const quizData = [
  {
    type: QuizType.Bubbles,
    title: 'Basic Signs',
    signs: [
      {
        difficulty: Difficulty.Easy,
        name: "Hello",
        s3Url: "url",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        name: "Goodbye",
        s3Url: "url",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        name: "Thank you",
        s3Url: "url",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        name: "Please",
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
        name: "Good morning",
        s3Url: "url",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        name: "Good night",
        s3Url: "url",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        name: "Good afternoon",
        s3Url: "url",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        name: "Good evening",
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
        name: "How are you?",
        s3Url: "url",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        name: "What is your name?",
        s3Url: "url",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        name: "Where are you from?",
        s3Url: "url",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        name: "What do you do?",
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
        name: "Hello",
        signGif: "how-are-you",
        matchIndex: 0,
      },
      {
        name: "Goodbye",
        signGif: "how-are-you",
        matchIndex: 1,
      },
      {
        name: "Thank you",
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

const phraseData = [
  {
    id: 1,
    name: "I can't sleep. I've been tossing and turning all night",
    s3Url: 'url',
    description: 'A common greeting',
    difficulty: Difficulty.Easy,
    meaning: "ME CAN'T SLEEP ME TOSS-AND-TURN ALL-NIGHT",
    explanation: "Move your fuck, Then move your other fuck, And now get them together",
    price: 10,
    signs: [
      {
        name: "Me",
        s3Url: 'url',
        description: 'I ME',
        difficulty: Difficulty.Easy,
        explanation: "Move your fuck",
        meaning: "Fuck those kids up in the pit"
      },
      {
        name: "Can't",
        s3Url: 'url',
        description: 'Cannot',
        difficulty: Difficulty.Easy,
        explanation: "Just do it, nothing is impossible",
        meaning: "I am unable to make execute this "
      },
      {
        id: 2,
        name: 'Sleep',
        s3Url: 'url',
        description: 'Sleep',
        difficulty: Difficulty.Easy,
        explanation: "wiwiwi, then wawa",
        meaning: "I am gods eepiest soldier"
      },
      {
        name: "All Night",
        s3Url: 'url',
        description: 'All night',
        difficulty: Difficulty.Easy,
        explanation: "Get your index finger and fuck off, Then move your fuck",
        meaning: "5 seconds basically"
      },
    ]
  }
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
                  name: letter,
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

        await prisma.quiz.create({
          data: {
            type: quiz.type,
            title: "Fingerspell your name",
          }
        })
        continue; 
      }
      try {
        const createdQuiz = await prisma.quiz.create({
          data: {
            type: quiz.type,
            title: quiz.title,
          },
        });


        if (quiz.type === QuizType.Bubbles) {
          for (let j = 0; j < quiz.signs.length; j++) {
            const sign = quiz.signs[j];
            const createdSign = await prisma.sign.create({
              data: {
                name: sign.name,
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
                  name: pair.name,
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

async function createPhrases() {
  try {
    for (const phrase of phraseData) {
      const createdPhrase = await prisma.phrase.create({
        data: {
          id: phrase.id,
          name: phrase.name,
          s3Url: phrase.s3Url,
          description: phrase.description,
          explanation: phrase.explanation,
          meaning: phrase.meaning,
          difficulty: phrase.difficulty,
          price: phrase.price,
        }
      });

      for (const sign of phrase.signs) {
        const createdSign = await prisma.sign.create({
          data: {
            name: sign.name,
            s3Url: sign.s3Url,
            description: sign.description,
            difficulty: sign.difficulty,
            meaning: sign.meaning,
            explanation: sign.explanation
          }
        });
        await prisma.phraseSign.create({
          data: {
            phrase: {
              connect: {
                id: createdPhrase.id
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
      console.log(`Created phrase with ID: ${createdPhrase.id}`);
    }
  } catch (error) {
    console.error('Error in createPhrases function:', error);
    throw error; // Re-throw the error to be caught by the main function
  }
}

async function main() {
  console.log('Start seeding badges...');

  await createBadges();
  await createQuizes();
  await createPhrases();
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });