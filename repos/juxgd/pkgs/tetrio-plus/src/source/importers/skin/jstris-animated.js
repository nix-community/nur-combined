export const name = 'Jstris animated';
export const desc = 'Multiple PNGs or a gif at a 9.0 aspect ratio with 9 blocks';
export const extrainputs = ['delay'];

export function test(files) {
  if (files.length == 1 && files[0].type != 'image/gif')
    return false;

  return files.every(file => {
    let aspect = file.image.width / file.image.height;
    return aspect == 9;
  });
}

import splitgif from './converters/util/splitgif.js';
import jstris_tetrio from './converters/jstris_tetrio.js';
import { load as loadtetrioanim } from './tetrio-animated.js';
export async function load(files, storage, options) {
  if (files.length == 1 && files[0].type == 'image/gif')
    files = await splitgif(files[0], options);

  await loadtetrioanim(files.map(file => {
    let image = jstris_tetrio(file.image);
    let data = image.toDataURL('image/png');
    return { ...file, image, data };
  }), storage, options);
}
