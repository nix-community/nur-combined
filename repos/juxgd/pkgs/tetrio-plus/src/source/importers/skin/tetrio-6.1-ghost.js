export const name = 'TETR.IO v6.1.0 ghost';
export const desc = 'A 128x128 raster image with 2 blocks for ghost and topout pieces (48px by 48px, arranged 2 by 1)';
export const extrainputs = [];

import { KEYS, Validator } from './util.js';
export function test(files) {
  if (files.length != 1) return false;
  return new Validator(files[0])
    .blockMime('image/gif')
    .blockMime('image/svg+xml')
    .filename(KEYS.UNCONNECTED_GHOST)
    .dimension(128, 128)
    .isAllowed();
}

import t61g_t61cg from './converters/tetrio61ghost_tetrio61connectedghost.js';
import { load as loadconnectedghost } from './tetrio-6.1-connected-ghost.js';
export async function load(files, storage) {
  let file = files[0];
  let image = t61g_t61cg(file.image);
  let data = image.toDataURL('image/png');
  await loadconnectedghost([{ ...file, image, data }], storage);
}
