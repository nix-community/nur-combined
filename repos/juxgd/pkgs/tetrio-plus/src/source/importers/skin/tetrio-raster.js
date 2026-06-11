export const name = 'Tetrio png/jpg';
export const desc = 'A raster image at a 12.4 aspect ratio with 12 blocks';
export const extrainputs = [];

export function test(files) {
  if (files.length != 1) return false;
  if (files[0].type == 'image/gif' || files[0].type == 'image/svg+xml')
    return false;
  let aspect = files[0].image.width / files[0].image.height;
  return aspect == 12.4;
}
import t_t61, { SKIN, GHOST } from './converters/tetrio_tetrio61.js';
import { load as loadtetrio61 } from './tetrio-6.1.js';
import { load as loadtetrio61ghost } from './tetrio-6.1-ghost.js';
export async function load(files, storage) {
  let file = files[0];

  let image = t_t61(file.image, SKIN);
  let data = image.toDataURL('image/png');

  let ghostimage = t_t61(file.image, GHOST);
  let ghostdata = ghostimage.toDataURL('image/png');

  await loadtetrio61([{ ...file, image, data }], storage);
  await loadtetrio61ghost([{ ...file, image: ghostimage, data: ghostdata }], storage);
}
