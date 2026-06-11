/**
 * @param {Object} data the data object to load
 * @param {Storage} storage A browser-storage-like object with 'set' method
 * @returns {String} user-readable summary of the import results
 *
 *
 * Relies on migrate.js
 */
async function sanitizeAndLoadTPSE(data, storage, options={}) {
  function parseBoolean(key) {
    return async bool => {
      if (typeof bool !== 'boolean') return 'ERROR: Expected boolean';
      await storage.set({ [key]: bool });
      return 'success';
    }
  }

  function parseFile(key, mimeFilter) {
    return async dataUri => {
      let match = /^data:(.+?);base64,/.exec(dataUri);
      if (!match) return `ERROR: Missing/invalid file`;

      if (mimeFilter && !mimeFilter.test(match[1]))
        return `ERROR: invalid file type, expected ${mimeFilter} got ${match[1]}`;

      await storage.set({ [key]: dataUri });
      return 'success';
    }
  }

  function electronOnly(callback) {
    return async value => {
      if (!browser.electron)
        return 'Ignored: This option is only for the desktop client';
      return await callback(value);
    }
  }

  function filterValues(object, path, whitelist) {
    for (let key of Object.keys(object)) {
      if (whitelist.indexOf(key) == -1) {
        return {
          success: false,
          error: `ERROR: Unexpected value at ${path}.${key}`
        }
      }
    }
    return { success: true };
  }

  function isNone(value) {
    return (value === null || value === undefined);
  }

  const importers = {
    sfxEnabled: parseBoolean('sfxEnabled'),
    musicEnabled: parseBoolean('musicEnabled'),
    musicGraphEnabled: parseBoolean('musicGraphEnabled'),
    disableVanillaMusic: parseBoolean('disableVanillaMusic'),
    enableMissingMusicPatch: parseBoolean('enableMissingMusicPatch'),
    enableReplaySaver: parseBoolean('enableReplaySaver'),
    enableOSD: parseBoolean('enableOSD'),
    bgEnabled: parseBoolean('bgEnabled'),
    animatedBgEnabled: parseBoolean('animatedBgEnabled'),
    enableTouchControls: parseBoolean('enableTouchControls'),
    enableEmoteTab: parseBoolean('enableEmoteTab'),
    watermarkEnabled: parseBoolean('watermarkEnabled'),
    transparentBgEnabled: electronOnly(parseBoolean('transparentBgEnabled')),
    opaqueTransparentBackground: parseBoolean('opaqueTransparentBackground'),
    openDevtoolsOnStart: electronOnly(parseBoolean('openDevtoolsOnStart')),
    forceIPCFetch: electronOnly(parseBoolean('forceIPCFetch')),
      

    // not included in content packs to prevent footgunning
    // tetrioPlusEnabled: parseBoolean('tetrioPlusEnabled'),
    // hideTetrioPlusOnStartup: electronOnly(parseBoolean('hideTetrioPlusOnStartup')),

    // not included because dangerous
    // allowURLPackLoader
    // whitelistedLoaderDomains
    // enableCustomCss
    // customCss

    enableAllSongTweaker: parseBoolean('enableAllSongTweaker'),
    showLegacyOptions: parseBoolean('showLegacyOptions'),
    bypassBootstrapper: parseBoolean('bypassBootstrapper'),
    enableCustomMaps: parseBoolean('enableCustomMaps'),
    disableSuppressExitPrompt: electronOnly(parseBoolean('disableSuppressExitPrompt')),
    advancedSkinLoading: parseBoolean('advancedSkinLoading'),
    forceNearestScaling: parseBoolean('forceNearestScaling'),
    windowTitleStatus: electronOnly(parseBoolean('windowTitleStatus')),
    musicGraphBackground: parseBoolean('musicGraphBackground'),

    board: parseFile('board', /^image\/.+$/),
    queue: parseFile('queue', /^image\/.+$/),
    grid: parseFile('grid', /^image\/.+$/),
    // disabled because this feature may cause non-obvious crashes
    // will be enabled later on with some strict size checking
    // winterCompatEnabled: parseBoolean('winterCompatEnabled'),
    winter2022board: parseFile('winter2022board', /^image\/.+$/),
    winter2022queue: parseFile('winter2022queue', /^image\/.+$/),
    winter2023board: parseFile('winter2023board', /^image\/.+$/),
    winter2023queue: parseFile('winter2023queue', /^image\/.+$/),
    frosty2023snowcaps: parseFile('frosty2023snowcaps', /^image\/.+$/),

    particle_beam: parseFile('particle_beam', /^image\/.+$/),
    particle_beams_beam: parseFile('particle_beams_beam', /^image\/.+$/),
    particle_bigbox: parseFile('particle_bigbox', /^image\/.+$/),
    particle_box: parseFile('particle_box', /^image\/.+$/),
    particle_chip: parseFile('particle_chip', /^image\/.+$/),
    particle_chirp: parseFile('particle_chirp', /^image\/.+$/),
    particle_dust: parseFile('particle_dust', /^image\/.+$/),
    particle_fbox: parseFile('particle_fbox', /^image\/.+$/),
    particle_fire: parseFile('particle_fire', /^image\/.+$/),
    particle_particle: parseFile('particle_particle', /^image\/.+$/),
    particle_smoke: parseFile('particle_smoke', /^image\/.+$/),
    particle_star: parseFile('particle_star', /^image\/.+$/),
    particle_flake: parseFile('particle_flake', /^image\/.+$/),
  	rank_d: parseFile('rank_d', /^image\/.+$/),
  	rank_dplus: parseFile('rank_dplus', /^image\/.+$/),
  	rank_cminus: parseFile('rank_cminus', /^image\/.+$/),
  	rank_c: parseFile('rank_c', /^image\/.+$/),
  	rank_cplus: parseFile('rank_cplus', /^image\/.+$/),
  	rank_bminus: parseFile('rank_bminus', /^image\/.+$/),
  	rank_b: parseFile('rank_b', /^image\/.+$/),
  	rank_bplus: parseFile('rank_bplus', /^image\/.+$/),
  	rank_aminus: parseFile('rank_aminus', /^image\/.+$/),
  	rank_a: parseFile('rank_a', /^image\/.+$/),
  	rank_aplus: parseFile('rank_aplus', /^image\/.+$/),
  	rank_sminus: parseFile('rank_sminus', /^image\/.+$/),
  	rank_s: parseFile('rank_s', /^image\/.+$/),
  	rank_splus: parseFile('rank_splus', /^image\/.+$/),
  	rank_ss: parseFile('rank_ss', /^image\/.+$/),
  	rank_u: parseFile('rank_u', /^image\/.+$/),
  	rank_x: parseFile('rank_x', /^image\/.+$/),
    rank_xplus: parseFile('rank_xplus', /^image\/.+$/),
  	rank_z: parseFile('rank_z', /^image\/.+$/),
  	font_hun_png: parseFile('font_hun_png', /^image\/.+$/),
  	font_hun_fnt: parseFile('font_hun_fnt', null),
    achievements: parseFile('achievements', null),
    zenith: parseFile('zenith', /^image\/.+$/),
    zenith_2x: parseFile('zenith_2x', /^image\/.+$/),
    zenith_rank: parseFile('zenith_rank', /^image\/.+$/),
    zenith_expert: parseFile('zenith_expert', /^image\/.+$/),
    zenith_expert_2x: parseFile('zenith_expert_2x', /^image\/.+$/),
    zenith_duoleft: parseFile('zenith_duoleft', /^image\/.+$/),
    zenith_duoleft_2x: parseFile('zenith_duoleft_2x', /^image\/.+$/),
    zenith_duoright: parseFile('zenith_duoright', /^image\/.+$/),
    zenith_duoright_2x: parseFile('zenith_duoright_2x', /^image\/.+$/),
    zenith_expert_duoleft: parseFile('zenith_expert_duoleft', /^image\/.+$/),
    zenith_expert_duoleft_2x: parseFile('zenith_expert_duoleft_2x', /^image\/.+$/),
    zenith_expert_duoright: parseFile('zenith_expert_duoright', /^image\/.+$/),
    zenith_expert_duoright_2x: parseFile('zenith_expert_duoright_2x', /^image\/.+$/),
    skin: parseFile('skin', /^image\/.+$/),
    ghost: parseFile('ghost', /^image\/.+$/),
    skinAnim: parseFile('skinAnim', /^image\/.+$/),
    ghostAnim: parseFile('ghostAnim', /^image\/.+$/),
    skinAnimMeta: async object => {
      if (typeof object != 'object')
        return `ERROR: Expected object`;

      if (typeof object.frames != 'number' || object.frames < 1)
        return `ERROR: Expected positive numerical value at frame`;
      if (typeof object.delay != 'number' || object.delay < 1)
        return `ERROR: Expected positive numerical value at delay`;

      let whitelist = ['frames', 'delay'];
      for (let key of Object.keys(object))
        if (whitelist.indexOf(key) == -1)
          return `ERROR: Unexpected value at ${key}`;

      await storage.set({ skinAnimMeta: object });
      return 'success';
    },
    ghostAnimMeta: async object => {
      if (typeof object != 'object')
        return `ERROR: Expected object`;

      if (typeof object.frames != 'number' || object.frames < 1)
        return `ERROR: Expected positive numerical value at frame`;
      if (typeof object.delay != 'number' || object.delay < 1)
        return `ERROR: Expected positive numerical value at delay`;

      let whitelist = ['frames', 'delay'];
      for (let key of Object.keys(object))
        if (whitelist.indexOf(key) == -1)
          return `ERROR: Unexpected value at ${key}`;

      await storage.set({ ghostAnimMeta: object });
      return 'success';
    },
    customSoundAtlas: async (atlas, importData) => {
      if (typeof atlas != 'object') return `ERROR: Expected object`;
      for (let [key, value] of Object.entries(atlas)) {
        if (!Array.isArray(value))
          return `ERROR: Expected array at ${key}`;

        if (value.length != 2)
          return `ERROR: Expected length 2 at ${key}`;

        if (typeof value[0] != 'number')
          return `ERROR: Expected number at ${key}[0]`;
      }

      let ogg = importData['customSounds'];
      if (typeof ogg != 'string' || !/^data:audio\/.+?;base64,/.test(ogg))
        return `ERROR: Missing/invalid sound atlas soundfile`

      await storage.set({
        customSoundAtlas: JSON.parse(JSON.stringify(atlas)),
        customSounds: ogg
      });
      return 'success';
    },
    backgrounds: async (backgrounds, importData) => {
      let toSet = {};

      if (!Array.isArray(backgrounds)) return `ERROR: Expected array`;
      for (let bg of backgrounds) {
        if (typeof bg.id != 'string' || !/^[a-z]+$/.test(bg.id))
          return `ERROR: Expected lowercase alphabetical string at [].id`;

        if (typeof bg.filename != 'string')
          return `ERROR: Expected string at [].filename`;

        if (typeof bg.type != 'string')
          return `ERROR: Expected type at [].type`;

        if (Object.keys(bg).length != 3)
          return `ERROR: Unexpected extra keys at []`;

        if (!options.skipFileDependencies) {
          let img = importData['background-' + bg.id];
          if (typeof img != 'string' || !/^data:.+?;base64,/.test(img))
            return `ERROR: Missing/invalid image ${bg.id}`
          toSet['background-' + bg.id] = img;
        }
      }

      toSet.backgrounds = JSON.parse(JSON.stringify(backgrounds));
      await storage.set(toSet);
      return 'success';
    },
    animatedBackground: async (bg, importData) => {
      if (typeof bg != 'object') return `ERROR: Expected object`;
      if (typeof bg.id != 'string' || !/^[a-z]+$/.test(bg.id))
        return `ERROR: Expected lowercase alphabetical string at id`;

      if (typeof bg.filename != 'string')
        return `ERROR: Expected alphabetical string at filename`;

      if (Object.keys(bg).length != 2)
        return `ERROR: Unexpected extra keys`;

      let img = importData['background-' + bg.id];
      if (typeof img != 'string' || !/^data:image\/.+?;base64,/.test(img))
        return `ERROR: Missing/invalid image ${bg.id}`

      await storage.set({
        animatedBackground: bg,
        ['background-' + bg.id]: img
      });
      return 'success';
    },
    music: async (music, importData) => {
      let toSet = {};

      if (!Array.isArray(music)) return `ERROR: Expected array`;
      for (let song of music) {
        if (typeof song.id != 'string' || !/^[a-z]+$/.test(song.id))
          return `ERROR: Expected lowercase alphabetical string at [].id`;

        if (typeof song.filename != 'string')
          return `ERROR: Expected string at [].filename`;

        if (typeof song.override != 'string' && !isNone(song.override))
          return `ERROR: Expected string or null at [].override`;

        if (typeof song.metadata != 'object' || !song.metadata)
          return `ERROR: Expected object at [].metadata`;

        if (typeof song.metadata.name != 'string')
          return `ERROR: Expected string at [].metadata.name`;

        if (typeof song.metadata.jpname != 'string')
          return `ERROR: Expected string at [].metadata.jpname`;

        if (typeof song.metadata.artist != 'string')
          return `ERROR: Expected string at [].metadata.artist`;

        if (typeof song.metadata.jpartist != 'string')
          return `ERROR: Expected string at [].metadata.jpartist`;

        if (typeof song.metadata.source != 'string')
          return `ERROR: Expected string at [].metadata.source`;
        
        if (typeof song.metadata.normalizeDb != 'number')
          return `ERROR: Expected number at [].metadata.normalizeDb`;

        let genres = ['INTERFACE', 'CALM', 'BATTLE', 'DISABLED', 'OVERRIDE'];
        if (genres.indexOf(song.metadata.genre) === -1)
          return `ERROR: Unknown genre at [].metadata.genre`;

        if (typeof song.metadata.loop != 'boolean')
          return `ERROR: Expected boolean at [].metadata.loop`;

        if (typeof song.metadata.loopStart != 'number')
          return `ERROR: Expected number at [].metadata.loopStart`;

        if (typeof song.metadata.loopLength != 'number')
          return `ERROR: Expected number at [].metadata.loopLength`;

        for (let key of Object.keys(song.metadata)) {
          if (
            [
              'name', 'jpname', 'artist', 'jpartist', 'genre', 'source', 'loop',
              'loopStart', 'loopLength', 'hidden', 'normalizeDb'
            ].indexOf(key) == -1
          ) return `ERROR: Unexpected value at [].metadata.${key}`;
        }

        for (let key of Object.keys(song))
          if (['id', 'filename', 'metadata', 'override'].indexOf(key) == -1)
            return `ERROR: Unexpected value at [].${key}`;

        if (!options.skipFileDependencies) {
          let mp3 = importData['song-' + song.id];
          if (typeof mp3 != 'string' || !/^data:(video|audio)\/.+?;base64,/.test(mp3))
            return `ERROR: Missing/invalid songfile ${song.id}`
          toSet['song-' + song.id] = mp3;
        }
      }

      toSet.music = JSON.parse(JSON.stringify(music));
      await storage.set(toSet);
      return 'success';
    },
    musicGraph: async (graph, importData) => {
      let toSet = {};
      
      if (!Array.isArray(graph)) return `ERROR: Expected array`;
      for (let node of graph) {
        if (typeof node.id != 'number')
          return `ERROR: Expected number at [].id`;

        if (['normal', 'root'].indexOf(node.type) == -1)
          return `ERROR: Expected enum value at [].type`;

        if (typeof node.name != 'string')
          return `ERROR: Expected string at [].name`;

        if (!isNone(node.audio)) {
          if (typeof node.audio != 'string')
            return `ERROR: Expected string or null at [].audio`;

          if (!options.skipFileDependencies) {
            let mp3 = importData['song-' + node.audio];
            if (typeof mp3 != 'string' || !/^data:audio\/.+?;base64,/.test(mp3))
              return `ERROR: Missing/invalid songfile ${node.audio}`;
            toSet['song-' + node.audio] = mp3;
          }
        }

        if (!isNone(node.background)) {
          if (typeof node.background != 'string')
            return `ERROR: Expected string or null at [].background`;
          if (typeof node.backgroundLayer != 'number')
            return `ERROR: Expected number at [].backgroundLayer`;
          if (typeof node.backgroundArea != 'string')
            return `ERROR: Expected string at [].backgroundArea`;

          let bg = importData['background-' + node.background];
          if (!options.skipFileDependencies) {
            if (typeof bg != 'string' || !/^data:.+?\/.+?;base64,/.test(bg))
              return `ERROR: Missing/invalid background file ${node.background}`;
            toSet['background-' + node.background] = bg;
          }
        }

        if (typeof node.hidden != 'boolean')
          return `ERROR: Expected boolean value at [].hidden`;

        if (typeof node.singleInstance != 'boolean')
          return `ERROR: Expected boolean value at [].singleInstance`;

        if (typeof node.x != 'number')
          return `ERROR: Expected number at [].x`;

        if (typeof node.y != 'number')
          return `ERROR: Expected number at [].y`;

        if (typeof node.audioStart != 'number')
          return `ERROR: Expected number at [].audioStart`;

        if (typeof node.audioEnd != 'number')
          return `ERROR: Expected number at [].audioEnd`;

        if (!isNone(node.effects)) {
          if (typeof node.effects != 'object')
            return `ERROR: Expected object at [].effects`;

          if (typeof node.effects.volume != 'number' || node.effects.volume < 0)
            return `ERROR: Expected positive number at [].effects.volume`;

          if (typeof node.effects.speed != 'number' || node.effects.speed < 0)
            return `ERROR: Expected positive number at [].effects.speed`;
        }

        if (!Array.isArray(node.triggers))
          return `ERROR: Expected array at [].triggers`;

        for (let trigger of node.triggers) {
          if (['fork', 'goto', 'kill', 'random', 'dispatch', 'create', 'set'].indexOf(trigger.mode) == -1)
            return `ERROR: Expected enum value at [].triggers[].mode`;

          if (typeof trigger.target != 'number')
            return `ERROR: Expected number value at [].triggers[].target`;

          if (typeof trigger.event != 'string')
            return `ERROR: Expected string value at [].triggers[].event`;

          if (typeof trigger.predicateExpression != 'string')
            return `ERROR: Expected string value at [].triggers[].predicateExpression`;

          if (typeof trigger.dispatchEvent != 'string')
            return `ERROR: Expected string value at [].triggers[].dispatchEvent`;

          if (typeof trigger.dispatchExpression != 'string')
            return `ERROR: Expected string value at [].triggers[].dispatchExpression`;

          if (typeof trigger.setVariable != 'string')
            return `ERROR: Expected string value at [].triggers[].setVariable`;

          if (typeof trigger.setExpression != 'string')
            return `ERROR: Expected string value at [].triggers[].setExpression`;

          if (typeof trigger.timePassedDuration != 'number' || trigger.timePassedDuration < 0)
            return `ERROR: Expected positive number value at [].triggers[].timePassedDuration`;

          if (typeof trigger.preserveLocation != 'boolean')
            return `ERROR: Expected boolean value at [].triggers[].preserveLocation`;

          if (typeof trigger.locationMultiplier != 'number' || trigger.locationMultiplier < 0)
            return `ERROR: Expected positive number value at [].triggers[].locationMultiplier`;

          if (typeof trigger.crossfade != 'boolean')
            return `ERROR: Expected boolean value at [].triggers[].crossfade`;

          if (typeof trigger.crossfadeDuration != 'number' || trigger.crossfadeDuration < 0)
            return `ERROR: Expected positive number value at [].triggers[].crossfadeDuration`;

          if (typeof trigger.anchor != 'object')
            return `ERROR: Expected object at [].triggers[].anchor`;

          if (typeof trigger.anchor.origin != 'object')
            return `ERROR: Expected object at [].triggers[].anchor.origin`;

          if (typeof trigger.anchor.target != 'object')
            return `ERROR: Expected object at [].triggers[].anchor.target`;

          if (typeof trigger.anchor.origin.x != 'number')
            return `ERROR: Expected number at [].triggers[].anchor.origin.x`;

          if (typeof trigger.anchor.origin.y != 'number')
            return `ERROR: Expected number at [].triggers[].anchor.origin.y`;

          if (typeof trigger.anchor.target.x != 'number')
            return `ERROR: Expected number at [].triggers[].anchor.target.x`;

          if (typeof trigger.anchor.target.y != 'number')
            return `ERROR: Expected number at [].triggers[].anchor.target.y`;

          let result1 = filterValues(trigger, '[].triggers[]', [
            'mode', 'target', 'event', 'preserveLocation', 'anchor',
            'crossfade', 'crossfadeDuration', 'locationMultiplier',
            'dispatchEvent', 'timePassedDuration', 'predicateExpression',
            'dispatchExpression', 'setExpression', 'setVariable'
          ]);
          if (!result1.success) return result1.error;

          let result2 = filterValues(trigger.anchor, '[].triggers[].anchor', [
            'origin', 'target'
          ]);
          if (!result2.success) return result2.error;

          let result3 = filterValues(
            trigger.anchor.origin,
            '[].triggers[].anchor.origin',
            ['x', 'y']
          );
          if (!result3.success) return result3.error;

          let result4 = filterValues(
            trigger.anchor.target,
            '[].triggers[].anchor.target',
            ['x', 'y']
          );
          if (!result4.success) return result4.error;
        }

        let result5 = filterValues(node, '[]', [
          'id', 'type', 'name', 'audio', 'triggers', 'hidden', 'singleInstance',
          'x', 'y', 'effects', 'audioStart', 'audioEnd', 'background',
          'backgroundLayer', 'backgroundArea'
        ]);
        if (!result5.success) return result5.error;
      }

      toSet.musicGraph = graph;
      await storage.set(toSet);
      return 'success';
    },
    touchControlConfig: async config => {
      if (typeof config != 'object')
        return `ERROR: Expected object at $`;

      if (['touchpad', 'hybrid', 'keys'].indexOf(config.mode) == -1)
        return `ERROR: Expected enum value at $.mode`;

      if (typeof config.binding != 'object')
        return `ERROR: Expected object at $.binding`;

      if (typeof config.binding.L_left != 'string')
        return `ERROR: Expected string at $.binding.L_left`;
      if (typeof config.binding.L_right != 'string')
        return `ERROR: Expected string at $.binding.L_right`;
      if (typeof config.binding.L_up != 'string')
        return `ERROR: Expected string at $.binding.L_up`;
      if (typeof config.binding.L_down != 'string')
        return `ERROR: Expected string at $.binding.L_down`;
      if (typeof config.binding.R_left != 'string')
        return `ERROR: Expected string at $.binding.R_left`;
      if (typeof config.binding.R_right != 'string')
        return `ERROR: Expected string at $.binding.R_right`;
      if (typeof config.binding.R_up != 'string')
        return `ERROR: Expected string at $.binding.R_up`;
      if (typeof config.binding.R_down != 'string')
        return `ERROR: Expected string at $.binding.R_down`;

      if (!Array.isArray(config.keys))
        return `ERROR: Expected array at $.keys`;

      for (let key of config.keys) {
        if (typeof key.x != 'number')
          return `ERROR: Expected number at $.keys[].x`;
        if (typeof key.y != 'number')
          return `ERROR: Expected number at $.keys[].y`;
        if (typeof key.w != 'number')
          return `ERROR: Expected number at $.keys[].w`;
        if (typeof key.h != 'number')
          return `ERROR: Expected number at $.keys[].h`;
        if (['hover', 'tap'].indexOf(key.behavior) == -1)
          return `ERROR: Expected enum value at $.keys[].behavior`;
        if (typeof key.bind != 'string')
          return `ERROR: Expected string at $.keys[].bind`;

        let result1 = filterValues(key, '$.keys[]', [
          'x', 'y', 'w', 'h', 'behavior', 'bind'
        ]);
        if (!result1.success) return result1.error;
      }

      let result2 = filterValues(config, '$', [
        'mode', 'deadzone', 'binding', 'keys'
      ]);
      if (!result2.success) return result2.error;

      await storage.set({
        touchControlConfig: config
      });
      return 'success';
    }
  }

  const results = [];
  let { from, to } = await migrate({
    get(keys) { return data }, // It's technically complient
    set(pairs) { Object.assign(data, pairs) },
    remove(keys) {
      if (!Array.isArray(keys)) keys = [keys];
      for (let key of keys)
        delete data[key];
    }
  });
  if (from != to) {
    results.push(`[Data pack migrated from v${from} to v${to}]`)
  }

  for (let [name, importer] of Object.entries(importers)) {
    if (data[name] !== null && data[name] !== undefined) {
      results.push(name + ' | ' + await importer(data[name], data));
    } else {
      // results.push(name + ' | Ignored: No data in pack');
    }
  }

  return results.join('\n');
}
globalThis.sanitizeAndLoadTPSE = sanitizeAndLoadTPSE;
