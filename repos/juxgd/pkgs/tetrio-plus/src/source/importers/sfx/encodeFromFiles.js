import { fetchAtlas, decodeDefaults, decodeAudio } from './decode.js';
import encode from './encode.js';

export async function test(files) {
  let warnings = [];
  let audio = files.filter(file => {
    if (/^audio/.test(file.type)) return true;
    warnings.push(`Skipped non-audio file ${file.name}`);
    return false;
  });
  if (audio.length < files.length * 0.9)
    return { result: false };

  let atlas = await fetchAtlas();
  let valid = files.filter(file => {
    let [_, noExt, _ext] = /([^/]+?)(\..{0,5})?$/.exec(file.name) || [];
    if (atlas[noExt]) return true;
    warnings.push(`Skipped unknown sound effect file ${file.name}`);
    return false;
  });
  if (valid.length < audio.length * 0.5)
    return { result: false };

  return { result: true, warnings };
}

export async function load(files, storage, options) {
  let sprites = await decodeDefaults(status => (options&&options.log||(()=>{}))(status));
  let modified = [];

  for (let file of files) {
    let [_, noExt, _ext] = /([^/]+?)(\..{0,5})?$/.exec(file.name) || [];
    let sprite = sprites.filter(sprite => sprite.name == noExt)[0];
    if (!sprite) continue;
    modified.push(noExt);
    let buffer = file.buffer || await (await window.fetch(file.data)).arrayBuffer();
    sprite.buffer = await decodeAudio(buffer);
    sprite.duration = sprite.buffer.duration;
    sprite.offset = -1;
    sprite.modified = true;
  }

  await encode(sprites, storage);
  return { type: 'sfx', modified };
}
