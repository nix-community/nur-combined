export const name = 'TETR.IO v6.1.0 connected';
export const desc = 'A complex 1024x1024 raster image with 48px by 48px blocks (see wiki)';
export const extrainputs = [];

import { KEYS, Validator } from './util.js';
export function test(files) {
  if (files.length != 1) return false;
  return new Validator(files[0])
    .blockMime('image/gif')
    .blockMime('image/svg+xml')
    .filename(KEYS.CONNECTED)
    .dimension(1024, 1024)
    .isAllowed();
}
export async function load(files, storage) {
  const canvas = window.document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  canvas.width = 2048;
  canvas.height = 2048;
  ctx.drawImage(files[0].image, 0, 0, 2048, 2048);
  await storage.set({
    skin: canvas.toDataURL('image/png'),
    skinAnim: null,
    skinAnimMeta: null
  });
}
