export const name = 'Tetrio animated';
export const desc = 'Multiple PNGs or a gif at a 12.4 aspect ratio with 12 blocks';
export const extrainputs = ['delay'];

export function test(files) {
  if (files.length == 1 && files[0].type != 'image/gif')
    return false;

  return files.every(file => {
    let aspect = file.image.width / file.image.height;
    return aspect == 12.4;
  });
}

function frameProxy(files, converter) {
  return new Proxy(files, {
    get(target, key, receiver) {
      if (/^\d+$/.test(key)) {
        return converter(files[key]);
      }
      return Reflect.get(...arguments);
    }
  })
}

import splitgif from './converters/util/splitgif.js';
import { load as loadraster } from './tetrio-raster.js';
import { load as loadt61ca } from './tetrio-6.1-connected-animated.js';
import { load as loadt61cga } from './tetrio-6.1-connected-ghost-animated.js';
import t_t61, { SKIN, GHOST } from './converters/tetrio_tetrio61.js';
import t61_t61c from './converters/tetrio61_tetrio61connected.js';
import t61g_t61cg from './converters/tetrio61ghost_tetrio61connectedghost.js';
export async function load(files, storage, options) {
  if (files.length == 1 && files[0].type == 'image/gif')
    files = await splitgif(files[0], options);

  let frames = frameProxy(files, file => {
    let image = t61_t61c(t_t61(file.image, SKIN));
    let data = image.toDataURL('image/png');
    return { ...file, image, data };
  });
  let ghostFrames = frameProxy(files, file => {
    let image = t61g_t61cg(t_t61(file.image, GHOST));
    let data = image.toDataURL('image/png');
    return { ...file, image, data };
  });
  await loadt61ca(frames, storage, options);
  await loadt61cga(ghostFrames, storage, options);
}
