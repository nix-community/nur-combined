// ==UserScript==
// @name         Microplus Toolkit for TETR.IO
// @namespace    https://gitlab.com/UniQMG/tetrio-plus
// @version      0.2.5
// @description  Some functionality of TETR.IO PLUS reimplemented as a userscript
// @author       UniQMG
// @match        https://tetr.io
// @icon         https://tetr.io/favicon.ico
// @grant        unsafeWindow
// @grant        GM_getValue
// @grant        GM_setValue
// @grant        GM_deleteValue
// ==/UserScript==

// This is a userscript, loadable with a userscript manager.
// See https://gitlab.com/UniQMG/tetrio-plus/-/wikis/microplus for details

// Note: this userscript can be pasted directly into devtools or used as a bookmarklet (when minified), with some limitations:
// - It must be executed in a very precise time window before `tetrio.js` finishes loading for sound effects to work,
//   and before clicking 'join' for other features.
// - It falls back to localStorage to store tpse files, which is extremely tiny on most browsers.
//   The limit apparently can't be changed on Chrome, but on Firefox you can adjust
//   `dom.storage.default_quota` in `about:config`.

(function() {
  'use strict';

  // for bookmarklet usage
  if (typeof unsafeWindow == 'undefined') globalThis.unsafeWindow = window;
  if (typeof GM_getValue == 'undefined') globalThis.GM_getValue = ((key, def) => localStorage[key] ?? def);
  if (typeof GM_setValue == 'undefined') globalThis.GM_setValue = ((key, value) => localStorage[key] = value);
  if (typeof GM_deleteValue == 'undefined') globalThis.GM_deleteValue = (key => delete localStorage[key]);
  let version = typeof GM_info != 'undefined'
    ? 'v' + GM_info.script.version.replace(/[^\w\.]/g, '')
    : 'bookmarklet';

  let mp = '[µ+]';
  let tpse = {};
  try {
    tpse = JSON.parse(GM_getValue('tpse', "{}"));
    if (tpse == null || typeof tpse != 'object') {
      console.warn(mp, "Stored TPSE is invalid", GM_getValue('tpse'));
      GM_deleteValue('tpse');
      tpse = {};
    }
  } catch(ex) {
    console.warn(mp, "Failed to parse loaded tpse, clearing.", GM_getValue('tpse'));
    GM_deleteValue('tpse');
    tpse = {};
  }
  console.log(mp, "Microplus Toolkit for TETR.IO enabled. Don't report issues to TETR.IO/osk during use.", { tpse });

  if (unsafeWindow.Howl) {
    alert(mp + 'Microplus loaded too late, custom sound effects may be unavailable');
    console.warn(mp, 'Howler already loaded');
  }

  let mpMenu = document.createElement('div');
  mpMenu.classList.add('microplus-toolkit-menu');
  mpMenu.innerHTML = `
<style>
.microplus-toolkit-menu {
  z-index: 10000000; /* yes, this is the actual exact minimum required. 9999999 is covered by the global stats. */
  position: fixed;
  right: 0px;
  width: 655px;
  max-width: 60vw;
  max-height: 60vh;
  overflow: auto;

  --background: #EEE;
  --layer-1: #CCC;
  --text: #222;
  font-family: sans-serif;
  color: var(--text);
}
.microplus-toolkit-menu > .main-section {
  background: var(--background);
  padding: 2px;
}
.microplus-toolkit-menu > .main-section > h1 {
  margin: 0px;
  white-space: nowrap;
  style: inline;
  font-size: 1.2rem;
}
.microplus-toolkit-menu > .main-section > h1 > .version {
  font-size: 0.8rem;
  font-family: monospace;
}
.microplus-toolkit-menu > .main-section > .tagline {
  margin: 0px;
  font-size: 0.75rem;
  font-family: monospace;
}
.microplus-toolkit-menu > .main-section > .section {
  border: none;
  border-top: 2px solid var(--text);
  padding: 4px;
  margin-top: 4px;
  background-color: var(--layer-1);
}
.microplus-toolkit-menu > .main-section > .section > legend {
  margin-left: 12px;
  padding-left: 4px;
  padding-right: 4px;
  font-size: 1rem;
  background-color: var(--background);
  border: 2px solid var(--text);
  border-radius: 4px;
}
.microplus-toolkit-menu button, .microplus-toolkit-menu ::file-selector-button {
  border-radius: 0px;
  border-color: lightgray;
}
.microplus-toolkit-menu marquee {
  color: red;
  font-weight: bold;
  background: black;
}
</style>

<div class="main-section">
  <h1>
    Microplus Toolkit for TETR.IO
    <span class="version">
      ${version} |
      <a class="wiki" href="https://gitlab.com/UniQMG/tetrio-plus/-/wikis/microplus">Wiki</a>
    </span>
  </h1>
  <p class="tagline">
    A userscript version of TETR.IO PLUS with limited feature support, but that runs anywhere.
  </p>
  <fieldset class="section">
    <legend>Import settings from a file</legend>
    Warning: Microplus Toolkit does not validate TPSE files beyond ensuring they're valid JSON.
    Malformatted TPSE files may cause issues.<br>
    <input type="file" id="mp-select-file" accept=".tpse"><br>
    <button id="mp-set-tpse">Set TPSE and reload page</button>
  </fieldset>
  <fieldset class="section">
    <legend>Remove TPSE</legend>
    <button id="mp-remove-tpse">Remove current TPSE and reload page</button>
  </fieldset>
  <div>
    <span style="font-style: italic">
    Microplus will close automatically after starting TETR.IO
    </span>
  </div>
  <div style="color: red">
    Microplus Toolkit supports only skins, sound effects, and custom backgrounds. Custom music support is currently unavailable. See wiki page for more details.
  </div>
</div>
<marquee scrollamount="15">Do not report issues to TETR.IO or osk during use.</marquee>
  `;

  const particles = ["particle_beam", "particle_beams_beam", "particle_bigbox", "particle_box", "particle_chip", "particle_chirp", "particle_dust", "particle_fbox", "particle_fire", "particle_particle", "particle_smoke", "particle_star", "particle_flake"];
  const customBackgroundsEnabled = tpse.backgrounds?.length > 0;

  waitUntil(() => document.body, () => {
    document.body.appendChild(mpMenu);
    document.getElementById('mp-set-tpse').addEventListener('click', async () => {
      try {
        let fileInput = document.getElementById('mp-select-file');
        let reader = new FileReader();
        if (!fileInput.files[0]) {
          alert(`${mp} Please select a file first`);
          return;
        }
        reader.readAsText(fileInput.files[0]);
        await new Promise((res, rej) => {
          reader.onload = res;
          reader.onerror = rej;
        });
        let json = JSON.parse(reader.result);
        // tpse versions defined in source/shared/migrate.js - these are named after the tetrio plus version that introduced them,
        // but are not kept in sync and only updated when a migration is necessary.
        if (json.version != '0.27.3') {
          let confirmation = confirm(
            `${mp} TPSE file is v${json.version}, but this version of Microplus Toolkit is designed for v0.23.8. ` +
            `Microplus Toolkit does not provide TPSE migration functionality. This TPSE file may break TETR.IO, ` +
            `but if it doesn't work you can always remove it.\n\nUse this TPSE file anyway?`
          );
          if (!confirmation) return;
        }

        let invalidProps = new Set(Object.keys(json));
        let songAndBgProps = [...invalidProps].filter(prop => prop.startsWith('song-') || prop.startsWith('background-'));
        let validProps = [
          'version', 'skin', 'ghost', 'customSoundAtlas', 'customSounds', 'music', 'backgrounds', ...songAndBgProps,
          'board', 'queue', 'grid', ...particles, 'opaqueTransparentBackground', 'forceNearestScaling'
        ];
        for (let validProp of validProps)
          invalidProps.delete(validProp);
        for (let prop of [...invalidProps])
          delete json[prop];

        GM_setValue('tpse', JSON.stringify(json));

        alert(`${mp} TPSE file set (${invalidProps.size} unsupported keys ignored)`);
        console.log(mp, 'TPSE file set, with removed keys: ', invalidProps);
        window.location.reload();
      } catch(ex) {
        alert(mp + ' Failed to set TPSE file: ' + ex);
        console.error(mp, 'Failed to set TPSE file', ex);
      }
    });
    let removeTPSE = document.getElementById('mp-remove-tpse');
    if (GM_getValue('tpse', null) == null) {
      removeTPSE.disabled = true;
    } else {
      removeTPSE.addEventListener('click', () => {
        console.log(mp, 'TPSE cleared');
        GM_setValue('tpse', null);
        window.location.reload();
      });
    }

    let menus = document.getElementById("menus");
    waitUntil(() => !menus || menus.getAttribute('data-menu-type') !== 'none', () => mpMenu.style.display = 'none');
  });

  async function waitUntil(predicate, trigger) {
    while (!await predicate()) {
      await new Promise(res => setTimeout(res, 10));
    }
    await trigger();
  }

  let ogDefineProp = Object.defineProperty;
  Object.defineProperty = function(obj, prop, opts, ...etc) {
    // intercept the pixijs out-of-bounds error, we'd rather have texture weirdness* than a crashed game
    // *haven't actually seen any weirdness other than the expected missing sprites
    if (prop == 'frame' && opts?.get.toString().includes('this._frame')) {
      console.debug(mp, 'frame setter intercepted', obj, prop, opts, etc);
      let originalSetter = opts.set;
      opts.set = function(frame) {
        console.debug(mp, 'frame setter call intercepted', frame);
        // not sure what frame.type is (seen as 1), but xywh are pretty obvious
        if ((frame.x + frame.width > this.baseTexture.width) || (frame.y + frame.height > this.baseTexture.height)) {
          console.warn(mp, 'intercepting out-of-bounds texture access on ', this, 'with attempted frame', {...frame});
          Object.assign(frame, { x: 0, y: 0, width: this.baseTexture.width, height: this.baseTexture.height });
        }
        originalSetter.call(this, frame);
      }
    }
    return ogDefineProp(obj, prop, opts, ...etc);
  }

  if (tpse.skin || tpse.ghost) {
    console.log(mp, "TPSE has mino or ghost skin");
    waitUntil(() => unsafeWindow.DEVHOOK_CONNECTED_SKIN, () => {
      console.log(mp, "Calling DEVHOOK_CONNECTED_SKIN()");
      unsafeWindow.DEVHOOK_CONNECTED_SKIN();
    });
  } else {
    console.log(mp, "TPSE lacks mino or ghost skin");
  }

  let pixi = unsafeWindow.PIXI; // this shouldn't be present yet, but if microplus late-loaded then it'll be populated here
  if (pixi) setupPixiProxy();
  function setupPixiProxy() {
    if (tpse.forceNearestScaling) { // todo: test
      pixi.SCALE_MODES.LINEAR = pixi.SCALE_MODES.NEAREST;
    }
    if (customBackgroundsEnabled) {
      pixi.Application = new Proxy(pixi.Application, {
        construct(target, args) {
          console.log(mp, "Enabling transparent background with pixi constructor args", args);
          args[0].transparent = true;
          return new target(...args);
        }
      });
    }
  }
  Object.defineProperty(unsafeWindow, 'PIXI', {
    get() { return pixi; },
    set(val) { pixi = val; setupPixiProxy(); }
  });

  let refreshBackground = () => {}; // noop placeholder
  if (customBackgroundsEnabled) {
    waitUntil(() => document.getElementById('pixi'), () => {
      // todo: copypasted from the tetrioplus music graph impl, is this necessary?
      let gameCanvas = document.getElementById('pixi');
      gameCanvas.style.backgroundPosition = 'center';
      gameCanvas.style.backgroundSize = 'cover';
    });

    let container = document.createElement('div');
    container.id = 'microplus-custom-background-container';
    container.innerHTML = `
<style>
  #microplus-custom-background-container > .microplus-custom-background {
    top: 0;
    left: 0;
    width: 100vw;
    height: 100vh;
    position: fixed;
    object-fit: cover;
    z-index: -1;
  }
</style>
    `;
    document.body.appendChild(container);

    const key = 'microplus-custom-background';
    refreshBackground = () => {
      let bg = tpse.backgrounds[Math.floor(tpse.backgrounds.length * Math.random())];
      console.log(mp, 'Refreshing background', bg);
      let tex = tpse['background-' + bg.id];

      for (let old of container.querySelectorAll('.' + key)) {
        old.remove();
      }

      let el = bg.type == 'video' ? document.createElement('video') : new Image();
      el.src = tex;
      el.classList.add(key);
      if (bg.type == 'video') {
        el.preload = 'auto';
        el.loop = true;
        el.muted = true;
        el.play();
      }
      container.appendChild(el);
    };
  }

  // Discover calls to `new Image()` to watch and rewrite the src property
  let nativeImage = unsafeWindow.Image;
  unsafeWindow.Image = new Proxy(nativeImage, {
    construct(target, args) {
      let val = new target(...args);
      console.debug(mp, "New image created, waiting for first src assignment...");
      waitUntil(() => val.src != "", async () => {
        console.debug(mp, "First source assignment", val.src);

        // intentionally use no anchors - skins may have query parameters and will have a tetrio domain prefix
        let skinURL = /\/res\/skins\/(minos|ghost)\/connected(\.2x)?\.png/.exec(val.src);
        let sourceTex = skinURL && (skinURL[1] == 'minos' ? tpse.skin : tpse.ghost);
        if (sourceTex) {
          console.log(mp, "Redirecting mino skin request", val.src);
          if (skinURL[2] != '.2x') {
            // downscale to 1x texture
            let image = new Image();
            image.src = sourceTex;
            await new Promise(res => { image.onload = res; });
            let canvas = document.createElement('canvas');
            let res = skinURL[1] == 'minos' ? [1024, 1024] : [512, 512];
            canvas.width = res[0];
            canvas.height = res[1];
            canvas.getContext('2d').drawImage(image, 0, 0, res[0], res[1]);
            sourceTex = canvas.toDataURL('image/png');
          }
          val.src = sourceTex;
        }

        let boardURL = /\/res\/skins\/board\/generic\/(board|queue|grid).png/.exec(val.src);
        if (boardURL && tpse[boardURL[1]]) {
          console.log(mp, "Redirecting board skin request", val.src);
          val.src = tpse[boardURL[1]];
        }

        let particleURL = /\/res\/particles\/((?:beams\/)?[a-z]+).png/.exec(val.src);
        let particleID = particleURL && ('particle_' + particleURL[1].replace('/', '_'));
        if (particleID && tpse[particleID]) {
          console.log(mp, "Redirecting particle skin request", val.src, "as particle", particleID);
          val.src = tpse[particleID];
        }

        let backgroundURL = /\/res\/bg\/(\d+).jpg/.exec(val.src);
        if (backgroundURL && customBackgroundsEnabled) {
          refreshBackground();
          if (tpse.opaqueTransparentBackground) {
            // 1x1 black pixel
            val.src = `data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAIAAACQd1P` +
              `eAAAACXBIWXMAAC4jAAAuIwF4pT92AAAAB3RJTUUH5AYVBwk0XL/4QAAAABl0RVh0` +
              `Q29tbWVudABDcmVhdGVkIHdpdGggR0lNUFeBDhcAAAAMSURBVAjXY2BgYAAAAAQAA` +
              `Sc0JwoAAAAASUVORK5CYII=`;
          } else {
            // 1x1 transparent pixel
            val.src = `data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJ` +
              `AAAABmJLR0QAAAAAAAD5Q7t/AAAACXBIWXMAAA7DAAAOwwHHb6hkAAAAB3RJTUUH5A` +
              `QWBjQ7z1871gAAAAtJREFUCNdjYAACAAAFAAHiJgWbAAAAAElFTkSuQmCC`;
          }
        }
      });
      return val;
    }
  });

  if ((tpse.customSoundAtlas && tpse.customSounds) || tpse.music) {
    console.log(mp, "TPSE contains custom sounds or music");

    let old_fetch = unsafeWindow.fetch;
    unsafeWindow.fetch = function(url, ...args) {
      //console.log(mp, 'fetch', url, args);
      if (url.startsWith("/sfx/tetrio.opus.rsd") && tpse.customSounds && tpse.customSoundAtlas) {
        console.log(mp, "intercepted sound effects fetch");
        return {
          async arrayBuffer() {
            console.log(mp, "intercepted sound effects arrayBuffer call");
            let { customSounds, customSoundAtlas } = tpse;

            // copied from source/filters/sfx/sfx-request-filter.js
            
            let atlas = Object.entries(customSoundAtlas).map(([name, [offset, duration]]) => ({ name, offset, duration }));
            atlas.sort((a, b) => {
              if (a.offset < b.offset) return -1;
              if (a.offset > b.offset) return 1;
              return 0;
            });
            
            let temp_buffer = new ArrayBuffer(4);
            let view = new DataView(temp_buffer);
            
            let header_buffer = [];
            header_buffer.push(0x74, 0x52, 0x53, 0x44); // header
            view.setUint32(0, 1, true); // major
            header_buffer.push(...new Uint8Array(temp_buffer)); 
            view.setUint32(0, 0, true); // minor
            header_buffer.push(...new Uint8Array(temp_buffer));
            for (let { name, offset, duration } of atlas) {
              let name_buffer = new TextEncoder().encode(name);
              
              // atlas values are in milliseconds, but tetrio changed to using seconds with its new format
              view.setFloat32(0, offset/1000, true);
              header_buffer.push(...new Uint8Array(temp_buffer));
              
              view.setUint32(0, name_buffer.length, true);
              header_buffer.push(...new Uint8Array(temp_buffer));
              
              header_buffer.push(...name_buffer);
            }
            
            let last_sprite = atlas[atlas.length-1];
            view.setFloat32(0, (last_sprite.offset + last_sprite.duration)/1000, true);
            header_buffer.push(...new Uint8Array(temp_buffer));
            header_buffer.push(0, 0, 0, 0); // name length of last sprite
            
            // changed from source:
            // Uint8Array.fromBase64 isn't available in the version of electron tetrio desktop uses,
            // but it is in any modern browser.
            let audio_buffer = Uint8Array.fromBase64(customSounds.substring(customSounds.indexOf(';base64,') + ';base64,'.length));
            view.setUint32(0, audio_buffer.byteLength, true);
            header_buffer.push(...new Uint8Array(temp_buffer));
            
            let final_buffer = new Uint8Array(header_buffer.length + audio_buffer.length);
            final_buffer.set(header_buffer, 0);
            final_buffer.set(audio_buffer, header_buffer.length);
            
            console.log(mp, "final buffer", final_buffer)
            return final_buffer.buffer;
          }
        }
      }
      return old_fetch(url, ...args);
    }
      
    // intercept Howler.js to rewrite its arguments
    let howl = unsafeWindow.Howl; // this shouldn't be present yet, but if microplus late-loaded then it'll be populated here
    let musicLoop = 0;
    Object.defineProperty(unsafeWindow, 'Howl', {
      get() {
        return new Proxy(howl, {
          construct(target, args) {
            try {
              console.debug(mp, "new Howl", target, args);

              let howler = null;

              // todo: ripped from tetrio source, an automated way to read these would be nice
              let baseSongDefs = {
                random: ['kaze-no-sanpomichi','honemi-ni-shimiiru-karasukaze','inorimichite','muscat-to-shiroi-osara','natsuzora-to-syukudai','akindo','yoru-no-niji','akai-tsuchi-wo-funde','burari-tokyo','prism','back-water','burning-heart','hayate-no-sei','ice-eyes','ima-koso','risky-area','fuyu-no-jinkoueisei','hatsuyuki','kansen-gairo','chiheisen-wo-koete','moyase-toushi-yobisamase-tamashii','naraku-heno-abyssmaze','samurai-sword','super-machine-soul','uchuu-5239','ultra-super-heros','21seiki-no-hitobito','haru-wo-machinagara','go-go-go-summer','sasurai-no-hitoritabi','wakana','zange-no-ma','subarashii-nichijou','asphalt','madobe-no-hidamari','minamoto','sora-no-sakura','suiu','freshherb-wreath-wo-genkan-ni'],
                calm: ['kaze-no-sanpomichi','honemi-ni-shimiiru-karasukaze','inorimichite','muscat-to-shiroi-osara','natsuzora-to-syukudai','akindo','yoru-no-niji','akai-tsuchi-wo-funde','burari-tokyo','prism','fuyu-no-jinkoueisei','hatsuyuki','kansen-gairo','21seiki-no-hitobito','haru-wo-machinagara','go-go-go-summer','sasurai-no-hitoritabi','wakana','zange-no-ma','subarashii-nichijou','asphalt','madobe-no-hidamari','minamoto','sora-no-sakura','suiu','freshherb-wreath-wo-genkan-ni'],
                battle: ['back-water','burning-heart','hayate-no-sei','ice-eyes','ima-koso','risky-area','chiheisen-wo-koete','moyase-toushi-yobisamase-tamashii','naraku-heno-abyssmaze','samurai-sword','super-machine-soul','uchuu-5239','ultra-super-heros']
              };
              let match = /res\/bgm\/(.+?).mp3/.exec(args[0].src);
              if (tpse.music && match) {
                console.log(mp, "Beginning music rewrite for music", args[0]);
                let baseSongID = match[1];
                // we aren't rewriting the actual music definition here, so we have to piggyback on whether the song tetrio tried
                // to play is calm or battle music. This'll probably skew the rng a bit, but that shouldn't be much of a problem.
                let pool = baseSongDefs.calm.includes(baseSongID) ? 'calm' : baseSongDefs.battle.includes(baseSongID) ? 'battle' : 'random';

                let override = tpse.music.filter(song => song.override == baseSongID)[0];
                let songs = tpse.music.filter(song => song.metadata.genre.toLowerCase() == pool.toLowerCase());
                let song = override || songs[Math.floor(Math.random() * songs.length)];
                console.log(mp, "Rewriting howler arguments for song ID", baseSongID, "with pool", pool, "and custom song", song);
                // todo: graceful silent fail case, as is this'll start playing base tetrio music
                if (!song) throw new Error(mp + ' no song available for pool ' + pool + ' or overriding ' + baseSongID);
                args[0].src = tpse['song-' + song.id];
                args[0].sprite = {
                  // (if there's no loopLength but loop is true, the whole song is looped)
                  start: [0, song.metadata.loopStart, !song.metadata.loopLength && song.metadata.loop],
                  loop: [song.metadata.loopStart, song.metadata.loopLength, song.metadata.loop]
                };
                // body adapted from tetrio code, which checks against a steadily-incrementing integer to prevent
                // playing the loop segment if the howler has already been stopped. We keep track of our own here instead.
                // tetrio handles stopping the howler, though.
                let thisLoop = ++musicLoop;
                args[0].onload = function() {
                  howler.play('start');
                  // jump into loop segment if there's a loopLength set
                  if (song.metadata.loopLength) {
                    setTimeout(() => {
                      if (thisLoop != musicLoop) return;
                      howler.play('loop');
                    }, song.metadata.loopStart)
                  }
                }
              }
              howler = new target(...args);
              return howler;
            } catch(ex) {
              console.warn(mp, 'Failed to rewrite howler config', ex);
              return new target(...args);
            }
          }
        });
      },
      set(val) {
        howl = val;
      }
    });
  } else {
    console.log(mp, "TPSE lacks custom sounds or music");
  }
})();
