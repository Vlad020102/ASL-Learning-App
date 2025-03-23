import { PrismaClient } from '@prisma/client';
import { BadgeRarity, BadgeType } from '@prisma/client';

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

async function main() {
  console.log('Start seeding badges...');
  
  // Create badges
  for (const badge of badgeData) {
    const createdBadge = await prisma.badge.create({
      data: badge,
    });
    console.log(`Created badge with ID: ${createdBadge.id}`);
  }
  
  console.log('Seeding badges completed successfully');
}

main()
  .catch((e) => {
    console.error(e);
    process.exit(1);
  })
  .finally(async () => {
    await prisma.$disconnect();
  });