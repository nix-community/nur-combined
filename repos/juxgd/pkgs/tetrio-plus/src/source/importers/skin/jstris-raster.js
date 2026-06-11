export const name = 'Jstris png/jpg';
export const desc = 'A raster image at a 9.0 aspect ratio with 9 blocks';
export const extrainputs = [];

export function test(files) {
  if (files.length != 1) return false;
  if (files[0].type == 'image/gif') return false;
  let aspect = files[0].image.width / files[0].image.height;
  return aspect == 9;
}

import jstris_tetrio from './converters/jstris_tetrio.js';
import { load as loadtetrio } from './tetrio-raster.js';
export async function load(files, storage) {
  let file = files[0];
  let image = jstris_tetrio(file.image);
  let data = image.toDataURL('image/png');
  await loadtetrio([{ ...file, image, data }], storage);
}
