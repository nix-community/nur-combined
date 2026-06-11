export const name = 'TETR.IO v6.1.0';
export const desc = 'A 256x256 raster image with 12 blocks (48px by 48px, arranged 6 by 2)';
export const extrainputs = [];

import { KEYS, Validator } from './util.js';
export function test(files) {
  if (files.length != 1) return false;
  return new Validator(files[0])
    .blockMime('image/gif')
    .blockMime('image/svg+xml')
    .filename(KEYS.UNCONNECTED)
    .dimension(256, 256)
    .isAllowed();
}

import t61_t61c from './converters/tetrio61_tetrio61connected.js'
import { load as loadconnected } from './tetrio-6.1-connected.js';
export async function load(files, storage) {
  let file = files[0];
  let image = t61_t61c(file.image);
  let data = image.toDataURL('image/png');
  await loadconnected([{ ...file, image, data }], storage);
}
