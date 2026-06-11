import * as tetriosvg from './tetrio-svg.js';
import * as tetrioraster from './tetrio-raster.js';
import * as tetrioanim from './tetrio-animated.js';
import * as jstrisraster from './jstris-raster.js';
import * as jstrisconnected from './jstris-connected.js';
import * as jstrisanim from './jstris-animated.js';
import * as tetrio61 from './tetrio-6.1.js';
import * as tetrio61ghost from './tetrio-6.1-ghost.js';
import * as tetrio61connected from './tetrio-6.1-connected.js';
import * as tetrio61connectedghost from './tetrio-6.1-connected-ghost.js';
import * as tetrio61connectedanimated from './tetrio-6.1-connected-animated.js';
import * as tetrio61connectedghostanimated from './tetrio-6.1-connected-ghost-animated.js';

export const loaders = {
  tetrio61,
  tetrio61ghost,
  tetrio61connected,
  tetrio61connectedghost,
  tetrio61connectedanimated,
  tetrio61connectedghostanimated,
  tetriosvg,
  tetrioraster,
  tetrioanim,
  jstrisraster,
  jstrisconnected,
  jstrisanim
};
const multiloaders = {
  tetrio61multi: multi('tetrio61', 'tetrio61ghost'),
  tetrio61connectedmulti: multi('tetrio61connected', 'tetrio61connectedghost'),
  ...loaders,
};
function multi(...keys) {
  let subloaders = keys.map(key => loaders[key]);
  function findOrder(files) { // only works for 2
    let orders = [files.slice(), files.slice().reverse()];
    for (let io = 0; io < orders.length; io++)
      if (orders[io].every((file, i) => subloaders[i].test([file])))
        return orders[io];
    return null;
  }
  function test(files) {
    if (files.length != 2) return false;
    return !!findOrder(files);
  }
  async function load(files, storage) {
    findOrder(files).forEach((file, i) => subloaders[i].load([file], storage))
  }
  return { test, load };
}

export function guessFormat(files) {
  for (let [format, { test }] of Object.entries(multiloaders))
    if (test(files)) return format;
  return null;
}

export async function automatic(files, storage, options) {
  let format = guessFormat(files);
  (options&&options.log||(()=>{}))("Guessing skin format", format)
  let loader = multiloaders[format];
  if (!loader) throw new Error('Unable to determine format.');
  await loader.load(files, storage, options);
  return { type: 'skin', format: format };
}
