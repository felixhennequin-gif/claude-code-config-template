import { existsSync, mkdirSync, copyFileSync, readdirSync, statSync, appendFileSync, readFileSync, writeFileSync } from 'node:fs';
import { join, dirname, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { hashContent, readManifest, writeManifest, MANIFEST_PATH } from './manifest.js';

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
  const allStacks = ['express-api', 'prisma-patterns', 'react-frontend', 'symfony-api', 'ci-cd-pipeline'];
  const skipped = allStacks.filter((s) => !selectedStacks.includes(s));
  return new Set(skipped.map((s) => join('claude', 'skills', 'stacks', s)));
}

/**
 * Map a stack key to the Bash permission entries typically needed for it.
 */
const STACK_PERMISSIONS = {
  'express-api': ['Bash(npm:*)', 'Bash(npx:*)'],
  'prisma-patterns': ['Bash(npm:*)', 'Bash(npx:*)'],
  'react-frontend': ['Bash(npm:*)', 'Bash(npx:*)'],
  'symfony-api': ['Bash(composer:*)', 'Bash(php:*)'],
};

/**
 * Inject stack-specific permission entries into the copied settings.json.
 * Returns the list of entries that were added (for reporting).
 */
function injectStackPermissions(targetDir, selectedStacks) {
  const settingsPath = join(targetDir, '.claude', 'settings.json');
  if (!existsSync(settingsPath)) return [];

  const additions = new Set();
  for (const stack of selectedStacks) {
    for (const entry of STACK_PERMISSIONS[stack] || []) {
      additions.add(entry);
    }
  }
  if (additions.size === 0) return [];

  try {
    const settings = JSON.parse(readFileSync(settingsPath, 'utf8'));
    settings.permissions ??= { allow: [], deny: [] };
    settings.permissions.allow ??= [];
    const existing = new Set(settings.permissions.allow);
    const added = [];
    for (const entry of additions) {
      if (!existing.has(entry)) {
        settings.permissions.allow.push(entry);
        added.push(entry);
      }
    }
    writeFileSync(settingsPath, JSON.stringify(settings, null, 2) + '\n');
    return added;
  } catch (err) {
    console.error(`  warning: could not update ${settingsPath}: ${err.message}`);
    return [];
  }
}

/**
 * Ensure .gitignore has the required entries.
 */
function updateGitignore(targetDir) {
  const gitignorePath = join(targetDir, '.gitignore');
  const entries = ['CLAUDE.local.md', '.claude/settings.local.json', '.claude/.template-manifest.json'];

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
 * Walk a directory recursively, returning file paths relative to `base`.
 */
function walkFiles(dir, base = dir) {
  const out = [];
  if (!existsSync(dir)) return out;
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      out.push(...walkFiles(full, base));
    } else {
      out.push(relative(base, full));
    }
  }
  return out;
}

/**
 * Build and persist the template manifest for every path that was just copied.
 * `copiedPaths` is a list of target-relative paths.
 */
function persistManifest(targetDir, copiedPaths) {
  if (copiedPaths.length === 0) return null;
  const manifest = { ...readManifest(targetDir) };
  for (const p of copiedPaths) {
    if (p === MANIFEST_PATH) continue;
    const full = join(targetDir, p);
    if (!existsSync(full)) continue;
    manifest[p] = hashContent(readFileSync(full, 'utf8'));
  }
  writeManifest(targetDir, manifest);
  return copiedPaths.length;
}

/**
 * Main copy function.
 */
export function copyTemplate(targetDir, selectedStacks) {
  const results = [];
  const copiedPaths = [];

  // 1. Copy CLAUDE.md
  const claudeMdSrc = join(TEMPLATE_DIR, 'CLAUDE.md');
  const claudeMdDest = join(targetDir, 'CLAUDE.md');
  if (existsSync(claudeMdDest)) {
    results.push({ file: 'CLAUDE.md', status: 'skipped', reason: 'already exists' });
  } else {
    copyFileSync(claudeMdSrc, claudeMdDest);
    results.push({ file: 'CLAUDE.md', status: 'copied' });
    copiedPaths.push('CLAUDE.md');
  }

  // 2. Copy CLAUDE.local.md.example → CLAUDE.local.md
  const localSrc = join(TEMPLATE_DIR, 'CLAUDE.local.md.example');
  const localDest = join(targetDir, 'CLAUDE.local.md');
  if (existsSync(localDest)) {
    results.push({ file: 'CLAUDE.local.md', status: 'skipped', reason: 'already exists' });
  } else {
    copyFileSync(localSrc, localDest);
    results.push({ file: 'CLAUDE.local.md', status: 'copied' });
    copiedPaths.push('CLAUDE.local.md');
  }

  // 2b. Copy .claudeignore (context-budget ignore list)
  const ignoreSrc = join(TEMPLATE_DIR, '.claudeignore');
  const ignoreDest = join(targetDir, '.claudeignore');
  if (existsSync(ignoreSrc)) {
    if (existsSync(ignoreDest)) {
      results.push({ file: '.claudeignore', status: 'skipped', reason: 'already exists' });
    } else {
      copyFileSync(ignoreSrc, ignoreDest);
      results.push({ file: '.claudeignore', status: 'copied' });
      copiedPaths.push('.claudeignore');
    }
  }

  // 3. Copy .claude/ directory (with dot prefix), skipping unselected stacks
  const claudeDirSrc = join(TEMPLATE_DIR, 'claude');
  const claudeDirDest = join(targetDir, '.claude');
  const skipPaths = getSkipPaths(selectedStacks);

  // settings.local.json.example is install-time only: it gets renamed to
  // settings.local.json in the target and the .example file itself is not shipped.
  skipPaths.add(join('claude', 'settings.local.json.example'));

  if (existsSync(claudeDirDest)) {
    results.push({ file: '.claude/', status: 'skipped', reason: 'already exists — delete it first to re-scaffold' });
  } else {
    copyDirRecursive(claudeDirSrc, claudeDirDest, skipPaths);
    results.push({ file: '.claude/', status: 'copied' });
    for (const rel of walkFiles(claudeDirDest)) {
      copiedPaths.push(join('.claude', rel));
    }

    // Install settings.local.json from the .example template (skip if user already has one)
    const settingsLocalSrc = join(TEMPLATE_DIR, 'claude', 'settings.local.json.example');
    const settingsLocalDest = join(claudeDirDest, 'settings.local.json');
    if (existsSync(settingsLocalSrc) && !existsSync(settingsLocalDest)) {
      copyFileSync(settingsLocalSrc, settingsLocalDest);
      results.push({ file: '.claude/settings.local.json', status: 'copied' });
      copiedPaths.push(join('.claude', 'settings.local.json'));
    }

    const skippedStacks = ['express-api', 'prisma-patterns', 'react-frontend', 'symfony-api']
      .filter((s) => !selectedStacks.includes(s));
    if (skippedStacks.length > 0) {
      results.push({ file: `stacks removed: ${skippedStacks.join(', ')}`, status: 'info' });
    }
    if (selectedStacks.length > 0) {
      results.push({ file: `stacks kept: ${selectedStacks.join(', ')}`, status: 'info' });
    }

    const addedPerms = injectStackPermissions(targetDir, selectedStacks);
    if (addedPerms.length > 0) {
      results.push({ file: '.claude/settings.json', status: 'updated', reason: `added permissions: ${addedPerms.join(', ')}` });
    } else {
      results.push({ file: '.claude/settings.json', status: 'info', reason: 'edit permissions.allow to add entries for your stack commands' });
    }
  }

  // 4. Update .gitignore
  const gitignoreAdded = updateGitignore(targetDir);
  if (gitignoreAdded.length > 0) {
    results.push({ file: '.gitignore', status: 'updated', reason: `added ${gitignoreAdded.join(', ')}` });
  }

  // 5. Persist manifest of everything we just wrote
  const tracked = persistManifest(targetDir, copiedPaths);
  if (tracked) {
    results.push({ file: MANIFEST_PATH, status: 'updated', reason: `${tracked} files tracked for future --update` });
  }

  return results;
}
