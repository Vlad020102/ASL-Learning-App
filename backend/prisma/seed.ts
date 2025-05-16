import { targetModulesByContainer } from '@nestjs/core/router/router-module';
import { Difficulty, ExtrasType, PrismaClient, QuizType } from '@prisma/client';
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
        s3Url: "how-are-you",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        name: "Goodbye",
        s3Url: "how-are-you",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        name: "Thank you",
        s3Url: "how-are-you",
        options: "Hello, Goodbye, Thank you, Please"
      },
      {
        difficulty: Difficulty.Easy,
        name: "Please",
        s3Url: "how-are-you",
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
        s3Url: "how-are-you",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        name: "Good night",
        s3Url: "how-are-you",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        name: "Good afternoon",
        s3Url: "how-are-you",
        options: "Good morning, Good night, Good afternoon, Good evening"
      },
      {
        difficulty: Difficulty.Moderate,
        name: "Good evening",
        s3Url: "how-are-you",
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
        s3Url: "how-are-you",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        name: "What is your name?",
        s3Url: "how-are-you",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        name: "Where are you from?",
        s3Url: "how-are-you",
        options: "How are you?, What is your name?, Where are you from?, What do you do?"
      },
      {
        difficulty: Difficulty.Hard,
        name: "What do you do?",
        s3Url: "how-are-you",
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
    s3Url: 'how-are-you',
    description: 'A common greeting',
    difficulty: Difficulty.Easy,
    meaning: "ME CAN'T SLEEP ME TOSS-AND-TURN ALL-NIGHT",
    explanation: "Move your index finger in a circular motion, then move your hand in a tossing motion, and finally make a sleeping gesture.",
    price: 10,
    signs: [
      {
        name: "Me",
        s3Url: 'how-are-you',
        description: 'I ME',
        difficulty: Difficulty.Easy,
        explanation: "Move your index finger in a circular motion",
        meaning: "I am the one who is doing this action"
      },
      {
        name: "Can't",
        s3Url: 'how-are-you',
        description: 'Cannot',
        difficulty: Difficulty.Easy,
        explanation: "Move your hand in a tossing motion",
        meaning: "I am unable to do this action"
      },
      {
        id: 2,
        name: 'Sleep',
        s3Url: 'how-are-you',
        description: 'Sleep',
        difficulty: Difficulty.Easy,  
        explanation: "Make a sleeping gesture",
        meaning: "I am in a state of rest"
      },
      {
        name: "All Night",
        s3Url: 'how-are-you',
        description: 'All night',
        difficulty: Difficulty.Easy,
        explanation: "Move your hand in a tossing motion",
        meaning: "I have been awake for the entire night"
      },
    ]
  },
  {
    id: 2,
    name: "Hello, my favourite holiday is Halloween",
    s3Url: 'how-are-you',
    description: 'A common greeting',
    difficulty: Difficulty.Easy,
    meaning: "HELLO MY FAVOURITE HOLIDAY HALLOWEEN",
    explanation: "Move your hand as if waving hello, then point to yourself, and finally make a gesture for Halloween.",
    price: 10,
    signs: [
      {
        name: "Hello",
        s3Url: 'how-are-you',
        description: 'Hello sign',
        difficulty: Difficulty.Easy,
        explanation: "Make a waving gesture",
        meaning: "Greeting the other person"
      },
      {
        name: "My",
        s3Url: 'how-are-you',
        description: 'Me, myself',
        difficulty: Difficulty.Easy,
        explanation: "Point to yourself",
        meaning: "I am the one who is doing this action"
      },
      {
        id: 2,
        name: 'Favourite',
        s3Url: 'how-are-you',
        description: 'Describing something as favourite',
        difficulty: Difficulty.Easy,  
        explanation: "Make a gesture indicating preference",
        meaning: "This is my preferred choice"
      },
      {
        name: "Holiday",
        s3Url: 'how-are-you',
        description: 'Holiday as a special day',
        difficulty: Difficulty.Easy,
        explanation: "Make a gesture indicating a special day",
        meaning: "This is a day of significance" 
      },
      {
        name: "Halloween",
        s3Url: 'how-are-you',
        description: 'The Halloween holiday',
        difficulty: Difficulty.Easy,
        explanation: "Make a gesture indicating Halloween indicatin face paint",
        meaning: "The holiday is Halloween"
      },
    ]
  }
]

const extrasData = [
  // Article
  {
    title: "Advancements in ASL Recognition Technology",
    description: "New AI models are making ASL more accessible",
    link: "https://example.com/asl-tech",
    type: ExtrasType.Article,
    imageUrl: "https://via.placeholder.com/300x200?text=ASL+Tech"
  },
  {
    title: "ASL Connect",
    description: "Free ASL learning resources from Gallaudet University",
    link: "https://aslconnect.gallaudet.edu",
    type: ExtrasType.Article,
    imageUrl: "https://via.placeholder.com/300x200?text=ASL+Connect"
  },
  {
    title: "ASL in Media",
    description: "How American Sign Language is transforming media representation",
    link: "https://example.com/asl-media",
    type: ExtrasType.Article,
    imageUrl: "https://via.placeholder.com/300x200?text=ASL+in+Media"
  },
  {
    title: "National Association of the Deaf",
    description: "Civil rights organization serving deaf and hard-of-hearing individuals",
    link: "https://nad.org",
    type: ExtrasType.Article,
    imageUrl: "https://via.placeholder.com/300x200?text=NAD"
  },
  {
    title: "The Rise of ASL in Online Education",
    description: "A deep dive into how American Sign Language is becoming a staple in virtual classrooms.",
    link: "https://example.com/asl-online-education",
    type: ExtrasType.Article,
    imageUrl: "https://via.placeholder.com/300x200?text=ASL+Education"
  },

  // Book
  {
    title: "The Gallaudet Dictionary of American Sign Language",
    description: "A comprehensive reference book on ASL vocabulary and usage.",
    link: "https://example.com/gallaudet-dictionary",
    type: ExtrasType.Book,
    imageUrl: "https://via.placeholder.com/300x200?text=Book"
  },

  // Event
  {
    title: "ASL Immersion Weekend 2025",
    description: "A two-day intensive event for ASL learners and enthusiasts.",
    link: "https://example.com/asl-immersion-2025",
    type: ExtrasType.Event,
    imageUrl: "https://via.placeholder.com/300x200?text=Event"
  },
  {
    title: "ASL Poetry Night",
    description: "Virtual gathering of ASL poets and storytellers",
    link: "https://example.com/asl-poetry",
    type: ExtrasType.Event,
    imageUrl: "https://via.placeholder.com/300x200?text=Poetry+Night"
  },
  {
    title: "Deaf Culture Events Calendar",
    description: "Nationwide events celebrating Deaf culture and ASL",
    link: "https://example.com/deaf-events",
    type: ExtrasType.Event,
    imageUrl: "https://via.placeholder.com/300x200?text=Deaf+Events"
  },

  // Game
  {
    title: "SignQuest: Learn ASL Through Play",
    description: "An interactive mobile game that teaches ASL signs through fun quests and challenges.",
    link: "https://example.com/signquest-game",
    type: ExtrasType.Game,
    imageUrl: "https://via.placeholder.com/300x200?text=Game"
  },

  // Movie
  {
    title: "CODA: A Breakthrough Film",
    description: "The Oscar-winning film that brought Deaf culture to mainstream audiences",
    link: "https://example.com/coda",
    type: ExtrasType.Movie,
    imageUrl: "https://via.placeholder.com/300x200?text=CODA"
  },
  {
    title: "Silent Voices",
    description: "Documentary exploring the rich history of ASL",
    link: "https://example.com/silent-voices",
    type: ExtrasType.Movie,
    imageUrl: "https://via.placeholder.com/300x200?text=Silent+Voices"
  },
  {
    title: "Through Deaf Eyes",
    description: "A powerful documentary exploring the history and culture of the Deaf community.",
    link: "https://example.com/through-deaf-eyes",
    type: ExtrasType.Movie,
    imageUrl: "https://via.placeholder.com/300x200?text=Movie"
  },

  // News
  {
    title: "Deaf Awareness Week Events",
    description: "National celebrations and educational opportunities",
    link: "https://example.com/deaf-awareness",
    type: ExtrasType.News,
    imageUrl: "https://via.placeholder.com/300x200?text=Deaf+Awareness"
  },
  {
    title: "Deaf Community Celebrates New Accessibility Law",
    description: "Landmark legislation improves communication access for the deaf and hard-of-hearing.",
    link: "https://example.com/accessibility-law",
    type: ExtrasType.News,
    imageUrl: "https://via.placeholder.com/300x200?text=Accessibility+News"
  },

  // Podcast
  {
    title: "Hands & Voices: Stories from the Deaf World",
    description: "Conversations with leaders and learners shaping the ASL movement.",
    link: "https://example.com/hands-voices-podcast",
    type: ExtrasType.Podcast,
    imageUrl: "https://via.placeholder.com/300x200?text=Podcast"
  },
  {
    title: "Sign Language Today Podcast",
    description: "Weekly discussions on ASL learning and Deaf culture",
    link: "https://example.com/podcast1",
    type: ExtrasType.Podcast,
    imageUrl: "https://via.placeholder.com/300x200?text=Podcast+1"
  },
  {
    title: "Signs of Change Podcast",
    description: "Interviews with Deaf activists and educators",
    link: "https://example.com/signs-change",
    type: ExtrasType.Podcast,
    imageUrl: "https://via.placeholder.com/300x200?text=Signs+of+Change"
  }
];


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

async function createExtras() {
  try {
    for (const extra of extrasData) {
      await prisma.extras.create({
        data: {
          title: extra.title,
          description: extra.description,
          link: extra.link,
          type: extra.type,
          imageUrl: extra.imageUrl
        }
      });
    }
    console.log("Extras created successfully!");
  } catch (error) {
    console.error('Error in createExtras function:', error);
    throw error;
  }
}

async function main() {
  console.log('Start seeding badges...');

  // await createBadges();
  // await createQuizes();
  await createPhrases();
  // await createExtras();
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });