import { createHash } from 'node:crypto';
import { readFileSync, writeFileSync, existsSync } from 'node:fs';
import { join } from 'node:path';

export const MANIFEST_PATH = '.claude/.template-manifest.json';

export function hashContent(content) {
  return createHash('sha256').update(content).digest('hex');
}

export function readManifest(targetDir) {
  const p = join(targetDir, MANIFEST_PATH);
  if (!existsSync(p)) return {};
  try {
    return JSON.parse(readFileSync(p, 'utf8'));
  } catch (err) {
    console.error(`  warning: could not read ${MANIFEST_PATH}: ${err.message}`);
    return {};
  }
}

export function writeManifest(targetDir, manifest) {
  const p = join(targetDir, MANIFEST_PATH);
  writeFileSync(p, JSON.stringify(manifest, null, 2) + '\n');
}
