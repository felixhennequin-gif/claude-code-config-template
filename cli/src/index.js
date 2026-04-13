import { resolve } from 'node:path';
import { existsSync } from 'node:fs';
import { askQuestions } from './prompts.js';
import { copyTemplate } from './copy.js';

export async function run() {
  console.log('\n⚡ create-claude-config\n');

  const { targetDir, stacks } = await askQuestions();
  const resolvedDir = resolve(targetDir);

  if (!existsSync(resolvedDir)) {
    console.error(`Error: directory "${resolvedDir}" does not exist.`);
    process.exit(1);
  }

  console.log('');

  const results = copyTemplate(resolvedDir, stacks);

  for (const r of results) {
    const icon = r.status === 'copied' ? '✓' :
                 r.status === 'updated' ? '✓' :
                 r.status === 'skipped' ? '⊘' :
                 'ℹ';
    const detail = r.reason ? ` (${r.reason})` : '';
    console.log(`  ${icon} ${r.file}${detail}`);
  }

  console.log('\nDone! Edit CLAUDE.md with your project info.\n');
}
