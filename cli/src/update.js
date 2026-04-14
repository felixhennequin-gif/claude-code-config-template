import { existsSync, readFileSync, copyFileSync, mkdirSync, readdirSync, statSync } from 'node:fs';
import { join, dirname, relative, sep } from 'node:path';
import { fileURLToPath } from 'node:url';
import { readManifest, writeManifest, hashContent, MANIFEST_PATH } from './manifest.js';

const __dirname = dirname(fileURLToPath(import.meta.url));
const TEMPLATE_DIR = join(__dirname, '..', 'template-files');

function walkDirSync(dir, base) {
  const results = [];
  for (const entry of readdirSync(dir)) {
    const full = join(dir, entry);
    if (statSync(full).isDirectory()) {
      results.push(...walkDirSync(full, base));
    } else {
      results.push(relative(base, full));
    }
  }
  return results;
}

export function updateTemplate(targetDir) {
  const results = [];
  const manifest = readManifest(targetDir);

  if (Object.keys(manifest).length === 0) {
    return [{
      file: MANIFEST_PATH,
      status: 'error',
      reason: 'No manifest found. This project was not installed with create-claude-code-config >= 0.8.0. Run the install command first, or install manually.',
    }];
  }

  const templateFiles = walkDirSync(TEMPLATE_DIR, TEMPLATE_DIR);
  const newManifest = { ...manifest };

  for (const relPath of templateFiles) {
    // Map template-files/ paths to target paths:
    //   "claude/hooks/bash-safety.sh" → ".claude/hooks/bash-safety.sh"
    //   "CLAUDE.md"                   → "CLAUDE.md"
    //   ".claudeignore"               → ".claudeignore"
    const targetRelPath =
      relPath.startsWith('claude' + sep) || relPath.startsWith('claude/')
        ? '.' + relPath
        : relPath;

    // CLAUDE.local.md.example is intentionally not updated — users copy it
    // to CLAUDE.local.md and customize it. The .example file is install-only.
    if (relPath === 'CLAUDE.local.md.example') {
      continue;
    }

    // settings.local.json.example is install-only — same pattern as above.
    // The installer renames it to settings.local.json and the user customizes it.
    if (relPath === join('claude', 'settings.local.json.example')) {
      continue;
    }

    // settings.json is excluded from --update — it contains user-specific
    // permissions injected at install time. Update it manually if needed.
    if (targetRelPath === '.claude/settings.json') {
      results.push({ file: targetRelPath, status: 'skipped', reason: 'excluded from auto-update (edit manually)' });
      continue;
    }

    const srcPath = join(TEMPLATE_DIR, relPath);
    const destPath = join(targetDir, targetRelPath);
    const srcContent = readFileSync(srcPath, 'utf8');
    const srcHash = hashContent(srcContent);

    if (!existsSync(destPath)) {
      mkdirSync(dirname(destPath), { recursive: true });
      copyFileSync(srcPath, destPath);
      newManifest[targetRelPath] = srcHash;
      results.push({ file: targetRelPath, status: 'copied', reason: 'new in template' });
      continue;
    }

    const destContent = readFileSync(destPath, 'utf8');
    const destHash = hashContent(destContent);
    const knownHash = manifest[targetRelPath];

    if (srcHash === destHash) {
      results.push({ file: targetRelPath, status: 'ok', reason: 'already up to date' });
      newManifest[targetRelPath] = srcHash;
      continue;
    }

    if (destHash === knownHash) {
      mkdirSync(dirname(destPath), { recursive: true });
      copyFileSync(srcPath, destPath);
      newManifest[targetRelPath] = srcHash;
      results.push({ file: targetRelPath, status: 'updated' });
    } else if (!knownHash) {
      results.push({ file: targetRelPath, status: 'skipped', reason: 'not in manifest — reinstall on a clean directory to track this file' });
    } else {
      results.push({ file: targetRelPath, status: 'skipped', reason: 'customized — update manually' });
    }
  }

  writeManifest(targetDir, newManifest);
  return results;
}
