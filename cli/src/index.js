import { resolve } from 'node:path';
import { existsSync } from 'node:fs';
import { askQuestions } from './prompts.js';
import { copyTemplate } from './copy.js';
import { updateTemplate } from './update.js';

function iconFor(status) {
  switch (status) {
    case 'copied':
    case 'updated':
    case 'ok':
      return '✓';
    case 'skipped':
      return '⊘';
    case 'error':
      return '✗';
    default:
      return 'ℹ';
  }
}

function printResults(results) {
  for (const r of results) {
    const detail = r.reason ? ` (${r.reason})` : '';
    console.log(`  ${iconFor(r.status)} ${r.file}${detail}`);
  }
}

function runUpdate() {
  console.log('\n⚡ create-claude-code-config --update\n');

  const args = process.argv.slice(2);
  const idx = args.indexOf('--update');
  const targetArg = idx >= 0 && args[idx + 1] && !args[idx + 1].startsWith('-') ? args[idx + 1] : '.';
  const resolvedDir = resolve(targetArg);

  if (!existsSync(resolvedDir)) {
    console.error(`Error: directory "${resolvedDir}" does not exist.`);
    process.exit(1);
  }

  const results = updateTemplate(resolvedDir);
  printResults(results);

  if (results.some((r) => r.status === 'error')) {
    process.exit(1);
  }

  const updated = results.filter((r) => r.status === 'updated' || r.status === 'copied').length;
  const skipped = results.filter((r) => r.status === 'skipped').length;
  const ok = results.filter((r) => r.status === 'ok').length;
  console.log(`\n${updated} updated, ${skipped} skipped (customized), ${ok} already up to date\n`);
}

export async function run() {
  if (process.argv.includes('--update')) {
    runUpdate();
    return;
  }

  console.log('\n⚡ create-claude-code-config\n');

  const { targetDir, stacks } = await askQuestions();
  const resolvedDir = resolve(targetDir);

  if (!existsSync(resolvedDir)) {
    console.error(`Error: directory "${resolvedDir}" does not exist.`);
    process.exit(1);
  }

  console.log('');

  const results = copyTemplate(resolvedDir, stacks);
  printResults(results);

  console.log('\nDone! Edit CLAUDE.md with your project info.\n');
}
