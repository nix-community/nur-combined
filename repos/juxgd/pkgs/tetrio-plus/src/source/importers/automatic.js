import { test as sfxTest, load as sfxLoad } from './sfx/encodeFromFiles.js';
import { test as musicTest, load as musicLoad } from './music.js';
import { test as bgTest, load as bgLoad } from './background.js';
import genericTextures from './generic-texture.js';
import { populateImage } from '../shared/filehelper.js';
import /* non es6 */ '../shared/migrate.js';
import /* non es6 */ '../shared/tpse-sanitizer.js';
import /* non es6 */ '../lib/jszip.min.js';

export default async function automatic(importers, files, storage, options) {
  await window.migrate(storage); // Ensure 'version' is set
  if (files.every(file => file.name.endsWith('.zip'))) {
    if (options.zipdepth > 5)
      throw new Error("Refusing to open a zip nested more than 5 layers deep");

    let results = await Promise.all(files.map(async file => {
      let res = await window.fetch(file.data);
      let buffer = await (res.arrayBuffer());
      let zip = await JSZip.loadAsync(buffer);
      let mimes = {
        'png': 'image/png',
        'jpg': 'image/jpeg',
        'jpeg': 'image/jpeg',
        'gif': 'image/gif',
        'svg': 'image/svg',
        'webp': 'image/webp',

        'webm': 'video/webm',

        'mp3': 'audio/mpeg',
        'ogg': 'audio/ogg',
        'wav': 'audio/wav',
      };
      (options&&options.log||(()=>{}))("Importing files from zip " + file.name + "...");
      let files = await Promise.all(Object.values(zip.files).filter(file => {
        if (file.dir) return false; // skip directories
        // MacOS is user-hostile and litters these files everywhere
        // and then ACTIVELY HIDES THEM FROM THE USER
        // Also it stores metadata as ".$filename", meaning
        // `foo.png` -> `__MACOSX/.foo.png`, despite not being a png file.
        if (file.name.includes("__MACOSX")) return false;
        if (file.name.includes(".DS_Store")) return false;
        return true;
      }).map(async file => {
        return populateImage({
          name: file.name,
          type: mimes[file.name.split('.').slice(-1)[0]] || 'application/octet-stream',
          data: 'data:application/octet-stream;base64,' + await file.async('base64')
        })
      }));
      if (files.length > 5) {
        let joined = files.slice(0, 5).map(file => file.name).join(', ');
        (options&&options.log||(()=>{}))(`${files.length} files: ${joined}...`);
      } else {
        let joined = files.map(file => file.name).join(', ');
        (options&&options.log||(()=>{}))(`${files.length} files: ${joined}`);
      }
      return await automatic(importers, files, storage, {
        ...options,
        zipdepth: (options.zipdepth || 0) + 1
      });
    }));
    return { type: 'multi', results };
  }
  if (files.every(file => file.name.endsWith('.tpse'))) {
    (options&&options.log||(()=>{}))("Guessing import type TPSE");
    for (let file of files) {
      let json = JSON.parse(await (await window.fetch(file.data)).text());
      await window.sanitizeAndLoadTPSE(json, storage);
    }
    return { type: 'tpse' };
  }
  for (let [id, { test, load }] of Object.entries(genericTextures)) {
    if (await test(files)) {
      (options&&options.log||(()=>{}))("Guessing import type generic/" + id);
      return await load(files, storage, options);
    }
  }
  if (await bgTest(files)) {
    (options&&options.log||(()=>{}))("Guessing import type backgrounds");
    return await bgLoad(files, storage, options);
  }
  if (files.every(file => /^image/.test(file.type))) {
    (options&&options.log||(()=>{}))("Guessing import type skin");
    return await importers.skin.automatic(files, storage, options);
  }
  let sfxResult = await sfxTest(files);
  if (sfxResult.result) {
    (options&&options.log||(()=>{}))("Guessing import type sfx");
    for (let warning of sfxResult.warnings)
      (options&&options.log||(()=>{}))(warning);
    return { ...await sfxLoad(files, storage, options), warnings: sfxResult.warnings };
  }
  if (await musicTest(files)) {
    (options&&options.log||(()=>{}))("Guessing import type music");
    return await musicLoad(files, storage, options);
  }
  // TODO: backgrounds
  throw new Error("Unable to determine import type");
}
