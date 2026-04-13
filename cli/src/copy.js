import { existsSync, mkdirSync, copyFileSync, readdirSync, statSync, appendFileSync, readFileSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TEMPLATE_DIR = join(__dirname, '..', 'template-files');

/**
 * Recursively copy a directory, skipping entries in the skip set.
 */
function copyDirRecursive(src, dest, skipPaths = new Set()) {
  if (!existsSync(dest)) {
    mkdirSync(dest, { recursive: true });
  }

  for (const entry of readdirSync(src)) {
    const srcPath = join(src, entry);
    const destPath = join(dest, entry);
    const relPath = relative(TEMPLATE_DIR, srcPath);

    if (skipPaths.has(relPath)) continue;

    if (statSync(srcPath).isDirectory()) {
      copyDirRecursive(srcPath, destPath, skipPaths);
    } else {
      const destDir = dirname(destPath);
      if (!existsSync(destDir)) {
        mkdirSync(destDir, { recursive: true });
      }
      copyFileSync(srcPath, destPath);
    }
  }
}

/**
 * Build the set of stack skill directories to skip.
 */
function getSkipPaths(selectedStacks) {
  const allStacks = ['express-api', 'prisma-patterns', 'react-frontend', 'fastapi-backend'];
  const skipped = allStacks.filter((s) => !selectedStacks.includes(s));
  return new Set(skipped.map((s) => join('claude', 'skills', 'stacks', s)));
}

/**
 * Ensure .gitignore has the required entries.
 */
function updateGitignore(targetDir) {
  const gitignorePath = join(targetDir, '.gitignore');
  const entries = ['CLAUDE.local.md', '.claude/settings.local.json'];

  let existing = '';
  if (existsSync(gitignorePath)) {
    existing = readFileSync(gitignorePath, 'utf8');
  }

  const toAdd = entries.filter((e) => !existing.includes(e));
  if (toAdd.length > 0) {
    const suffix = existing.endsWith('\n') || existing === '' ? '' : '\n';
    appendFileSync(gitignorePath, suffix + toAdd.join('\n') + '\n');
  }

  return toAdd;
}

/**
 * Main copy function.
 */
export function copyTemplate(targetDir, selectedStacks) {
  const results = [];

  // 1. Copy CLAUDE.md
  const claudeMdSrc = join(TEMPLATE_DIR, 'CLAUDE.md');
  const claudeMdDest = join(targetDir, 'CLAUDE.md');
  if (existsSync(claudeMdDest)) {
    results.push({ file: 'CLAUDE.md', status: 'skipped', reason: 'already exists' });
  } else {
    copyFileSync(claudeMdSrc, claudeMdDest);
    results.push({ file: 'CLAUDE.md', status: 'copied' });
  }

  // 2. Copy CLAUDE.local.md.example → CLAUDE.local.md
  const localSrc = join(TEMPLATE_DIR, 'CLAUDE.local.md.example');
  const localDest = join(targetDir, 'CLAUDE.local.md');
  if (existsSync(localDest)) {
    results.push({ file: 'CLAUDE.local.md', status: 'skipped', reason: 'already exists' });
  } else {
    copyFileSync(localSrc, localDest);
    results.push({ file: 'CLAUDE.local.md', status: 'copied' });
  }

  // 3. Copy .claude/ directory (with dot prefix), skipping unselected stacks
  const claudeDirSrc = join(TEMPLATE_DIR, 'claude');
  const claudeDirDest = join(targetDir, '.claude');
  const skipPaths = getSkipPaths(selectedStacks);

  if (existsSync(claudeDirDest)) {
    results.push({ file: '.claude/', status: 'skipped', reason: 'already exists — delete it first to re-scaffold' });
  } else {
    copyDirRecursive(claudeDirSrc, claudeDirDest, skipPaths);
    results.push({ file: '.claude/', status: 'copied' });

    const skippedStacks = ['express-api', 'prisma-patterns', 'react-frontend', 'fastapi-backend']
      .filter((s) => !selectedStacks.includes(s));
    if (skippedStacks.length > 0) {
      results.push({ file: `stacks removed: ${skippedStacks.join(', ')}`, status: 'info' });
    }
    if (selectedStacks.length > 0) {
      results.push({ file: `stacks kept: ${selectedStacks.join(', ')}`, status: 'info' });
    }
  }

  // 4. Update .gitignore
  const gitignoreAdded = updateGitignore(targetDir);
  if (gitignoreAdded.length > 0) {
    results.push({ file: '.gitignore', status: 'updated', reason: `added ${gitignoreAdded.join(', ')}` });
  }

  return results;
}
