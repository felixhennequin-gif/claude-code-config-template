import { existsSync, readFileSync, writeFileSync, copyFileSync, mkdirSync, readdirSync, statSync } from 'node:fs';
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

// Additive merge of `hooks.{event}[].hooks[]` from the template's settings.json
// into the user's settings.json. Adds matcher groups and individual hooks that
// are missing on the user side, identified by `command` string. Never removes,
// never modifies existing entries, never touches `permissions` or other keys.
//
// Trade-off: a user who deliberately removed a default hook will see it
// re-added. They can re-remove it; this is preferred over leaving new shipped
// hooks silently unwired.
function mergeSettingsHooks(userPath, templatePath) {
  const user = JSON.parse(readFileSync(userPath, 'utf8'));
  const template = JSON.parse(readFileSync(templatePath, 'utf8'));
  const added = [];

  user.hooks ??= {};

  for (const event of Object.keys(template.hooks ?? {})) {
    const tplGroups = template.hooks[event] ?? [];
    user.hooks[event] ??= [];

    for (const tplGroup of tplGroups) {
      const userGroup = user.hooks[event].find((g) => (g.matcher ?? '') === (tplGroup.matcher ?? ''));

      if (!userGroup) {
        user.hooks[event].push(tplGroup);
        added.push(`${event}/${tplGroup.matcher ?? '(default)'}: full group (${(tplGroup.hooks ?? []).length} hook${(tplGroup.hooks ?? []).length === 1 ? '' : 's'})`);
        continue;
      }

      userGroup.hooks ??= [];
      for (const tplHook of tplGroup.hooks ?? []) {
        const exists = userGroup.hooks.some((uh) => uh.command === tplHook.command);
        if (!exists) {
          userGroup.hooks.push(tplHook);
          added.push(`${event}/${tplGroup.matcher ?? '(default)'}: ${tplHook.command}`);
        }
      }
    }
  }

  if (added.length > 0) {
    writeFileSync(userPath, JSON.stringify(user, null, 2) + '\n');
  }
  return added;
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
    //   "claude/hooks/dangerous-rm-guard.sh" → ".claude/hooks/dangerous-rm-guard.sh"
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

    // settings.json gets a partial merge: only `hooks` are merged additively
    // (so new hooks shipped by the template auto-wire). Permissions and other
    // top-level keys remain user-controlled and untouched.
    if (targetRelPath === '.claude/settings.json') {
      const srcPath = join(TEMPLATE_DIR, relPath);
      const destPath = join(targetDir, targetRelPath);
      if (!existsSync(destPath)) {
        mkdirSync(dirname(destPath), { recursive: true });
        copyFileSync(srcPath, destPath);
        results.push({ file: targetRelPath, status: 'copied', reason: 'no user settings — copied from template' });
        continue;
      }
      try {
        const added = mergeSettingsHooks(destPath, srcPath);
        if (added.length > 0) {
          results.push({ file: targetRelPath, status: 'updated', reason: `merged ${added.length} new hook entr${added.length === 1 ? 'y' : 'ies'}: ${added.join('; ')}` });
        } else {
          results.push({ file: targetRelPath, status: 'ok', reason: 'hooks already in sync; permissions untouched' });
        }
      } catch (err) {
        results.push({ file: targetRelPath, status: 'skipped', reason: `merge failed (${err.message}) — edit manually` });
      }
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
