export const name = 'Jstris connected';
export const desc = 'A complex 576x1280 raster image (9:20) with 64px by 64px blocks (see wiki)';
export const extrainputs = [];

import { KEYS, Validator } from './util.js';
export function test(files) {
  if (files.length != 1) return false;
  return new Validator(files[0])
    .filename(KEYS.JSTRIS_CONNECTED)
    .dimension(576, 1280)
    .isAllowed();
}

import jc_t61c from './converters/jstrisconnected_tetrio61connectedmulti.js';
import { load as loadconnected } from './tetrio-6.1-connected.js';
import { load as loadconnectedghost } from './tetrio-6.1-connected-ghost.js';
export async function load(files, storage) {
  let [skin, ghost] = jc_t61c(files[0].image);

  await loadconnected([{
    ...files[0],
    image: skin,
    data: skin.toDataURL('image/png')
  }], storage);

  await loadconnectedghost([{
    ...files[0],
    image: ghost,
    data: ghost.toDataURL('image/png')
  }], storage);
}
