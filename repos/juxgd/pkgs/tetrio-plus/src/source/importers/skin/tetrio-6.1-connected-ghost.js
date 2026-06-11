export const name = 'TETR.IO v6.1.0 connected ghost';
export const desc = 'A complex 512x512 raster image with 48px by 48px blocks for ghost and topout pieces (see wiki)';
export const extrainputs = [];


import { KEYS, Validator } from './util.js';
export function test(files) {
  if (files.length != 1) return false;
  return new Validator(files[0])
    .blockMime('image/gif')
    .blockMime('image/svg+xml')
    .filename(KEYS.CONNECTED_GHOST)
    .dimension(512, 512)
    .isAllowed();
}
export async function load(files, storage) {
  const canvas = window.document.createElement('canvas');
  const ctx = canvas.getContext('2d');
  canvas.width = 1024;
  canvas.height = 1024;
  ctx.drawImage(files[0].image, 0, 0, 1024, 1024);
  await storage.set({
    ghost: canvas.toDataURL('image/png'),
    ghostAnim: null,
    ghostAnimMeta: null
  });
}
