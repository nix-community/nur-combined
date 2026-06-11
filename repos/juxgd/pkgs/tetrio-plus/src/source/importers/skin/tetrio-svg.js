export const name = 'Tetrio svg';
export const desc = 'An SVG at a 12.4 aspect ratio with 12 blocks';
export const extrainputs = [];

export function test(files) {
  if (files.length != 1) return false;
  if (files[0].type != 'image/svg+xml') return false;
  let aspect = files[0].image.width / files[0].image.height;
  return aspect == 12.4;
}
import { load as loadtetrioraster } from './tetrio-raster.js';
export async function load(files, storage) {
  let file = files[0];
  let svg = await (await window.fetch(files[0].data)).text();

  let canvas = window.document.createElement('canvas');
  let ctx = canvas.getContext('2d');
  canvas.width = file.image.width;
  canvas.height = file.image.height;
  ctx.drawImage(file.image, 0, 0);

  let data = canvas.toDataURL('image/png');
  await loadtetrioraster([{ ...file, image: canvas, data }], storage);
}
