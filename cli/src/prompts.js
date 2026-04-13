import prompts from 'prompts';

const STACKS = [
  { value: 'express-api', title: 'Express 5 (Node.js)' },
  { value: 'prisma-patterns', title: 'Prisma 7' },
  { value: 'react-frontend', title: 'React 19 + Tailwind v4' },
];

export async function askQuestions() {
  const onCancel = () => {
    console.log('\nAborted.');
    process.exit(0);
  };

  const response = await prompts([
    {
      type: 'text',
      name: 'targetDir',
      message: 'Project directory?',
      initial: '.',
    },
    {
      type: 'multiselect',
      name: 'stacks',
      message: 'Select stack skills (space to toggle, enter to confirm)',
      choices: STACKS,
      hint: '- Use arrow keys. Space to toggle. Enter to confirm. Leave empty for core only.',
      instructions: false,
    },
  ], { onCancel });

  return {
    targetDir: response.targetDir || '.',
    stacks: response.stacks || [],
  };
}
