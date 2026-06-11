import * as tetriosvg from './skin/tetrio-svg.js';
import * as tetrioraster from './skin/tetrio-raster.js';
import * as tetrioanim from './skin/tetrio-animated.js';
import * as jstrisraster from './skin/jstris-raster.js';
import * as jstrisconnected from './skin/jstris-connected.js';
import * as jstrisanim from './skin/jstris-animated.js';
import * as tetrio61 from './skin/tetrio-6.1.js';
import * as tetrio61ghost from './skin/tetrio-6.1-ghost.js';
import * as tetrio61connected from './skin/tetrio-6.1-connected.js';
import * as tetrio61connectedghost from './skin/tetrio-6.1-connected-ghost.js';
import { loaders, automatic, guessFormat } from './skin/automatic.js';

import genericTexture from './generic-texture.js';

import { decodeDefaults, decodeAudio } from './sfx/decode.js';
import encode from './sfx/encode.js';
import * as encodeFromFiles from './sfx/encodeFromFiles.js';

import automaticAny from './automatic.js';

import * as background from './background.js';

// Types:
// File format: { name: string, type: string, data: arraybuffer }
// Skin options: { delay: number, combine: boolean }
// Sprite: { name: string, buffer: AudioBuffer, offset: number, duration: number, modified: boolean }

const importers = {
  skin: {
    loaders: Object.values(loaders),
    knownAspectRatios: [['TETR.IO 6.1', 1], ['Tetrio', 12.4], ['Jstris', 9], ['Jstris connected', 0.45]],
    guessFormat: guessFormat, // file[] -> string|null
    automatic: automatic, // file[], storage, options
    tetriosvg: tetriosvg.load, // file[1], storage
    tetrioraster: tetrioraster.load, // file[1], storage
    tetrioanim: tetrioanim.load, // file[], storage, options
    jstrisraster: jstrisraster.load, // file[1], storage
    jstrisconnected: jstrisconnected.load, // file[1], storage
    jstrisanim: jstrisanim.load, // file[], storage, options
    tetrio61: tetrio61.load, // file[1], storage, options
    tetrio61connected: tetrio61connected.load // file[1], storage, options
  },
  sfx: {
    decodeAudio, // ArrayBuffer -> AudioBuffer
    decodeDefaults, // -> Sprite[]
    encode, // { [string]: Sprite }, storage
    encodeFromFiles: encodeFromFiles.load // file[], storage
  },
  genericTexture: genericTexture,
  background: background.load // file[], storage
};
// Imports anything, guessing at what it is.
importers.automatic = (...args) => automaticAny(importers, ...args);

export default importers;
