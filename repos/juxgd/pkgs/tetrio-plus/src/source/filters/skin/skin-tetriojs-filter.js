async function getRequiredResolution(storage) {
  let res = await storage.get([
    'skin', 'ghost', 'advancedSkinLoading', 'skinAnimMeta', 'ghostAnimMeta'
  ]);
  if (res.advancedSkinLoading && (res.skinAnimMeta || res.ghostAnimMeta))
    return 'hd';
  if (res.skin || res.ghost)
    return 'uhd';
  return null;
}
createRewriteFilter("UHD/HD forcer", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    return await getRequiredResolution(storage) != null;
  },
  onStop: async (storage, url, src, callback) => {
    let res = await getRequiredResolution(storage);
    let newSrc = src.replace(/["']uhd["']\s*:\s*["']hd["']/, `'${res}':'${res}'`)
    if (newSrc == src) console.warn('UHD Disabler hook broke (1/1)');
    callback({ type: 'text/javascript', data: newSrc, encoding: 'text' });
  }
});

createRewriteFilter("Scale mode forcer", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get('forceNearestScaling');
    return res.forceNearestScaling;
  },
  onStop: async (storage, url, src, callback) => {
    let newSrc = src.replace(
      /(\w{1,5}\s*=\s*new\s*(\w+)\.Application\({)/g,
      `$1__:void (() => { $2.settings.SCALE_MODE=$2.SCALE_MODES.NEAREST; })(),`
    );
    if (newSrc == src) console.warn('Scale mode forcer hook broke (1/1)');
    callback({ type: 'text/javascript', data: newSrc, encoding: 'text' });
  }
});

createRewriteFilter("Advanced skin loader", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, request) => {
    let res = await storage.get([
      'advancedSkinLoading',
      'skinAnimMeta',
      'ghostAnimMeta'
    ]);
    return res.advancedSkinLoading && (res.skinAnimMeta || res.ghostAnimMeta);
  },
  onStop: async (storage, url, source, callback) => {
    let finalSource = source;
    try {
      const res = await storage.get(['skinAnimMeta', 'ghostAnimMeta']);

      // Replace standard spritesheet with animated one by tacking on ?animated
      // (see skin-request-filter.js for route)
      source = source.replace(
        /(\/res\/skins\/(minos|ghost)\/connected.png)/g,
        "$1?animated"
      );

      // one time init to read control events from the music graph
      source = `
        window.__tetrioPlusAdvSkinLoader = { manualControl: false, frame: 0 };
        document.addEventListener('tetrio-plus-set-skin-manual-control', evt => {
          window.__tetrioPlusAdvSkinLoader.manualControl = evt.detail;
        });
        document.addEventListener('tetrio-plus-set-skin-frame', evt => {
          window.__tetrioPlusAdvSkinLoader.frame = evt.detail;
        });
      ` + source;

      // Set up animated textures by intercepting skin texture setup
      // Example of matched code: ```
      // function Lp(e,t,n,s,i,r){const a={};return Object.keys(t).forEach((l=>{a[l]=new o.Texture(e,new o.Rectangle(s+(t[l][0]+i)*(n+2*s),s+(t[l][1]+r)*(n+2*s),n,n))}
      // ```
      var regex = /(\w+\((\w+),\s*(\w+),\s*(\w+),\s*(\w+),\s*(\w+),\s*(\w+)\)\s*{[\S\s]{0,200}Object\.keys\(\3\)\.forEach\(\(\w\s*=>\s*{)([\S\s]+?)}/
      var match = false;
      source = source.replace(regex, (_$, prefix, _a1, _a2, _a3, _a4, _a5, _a6, loopBody) => {
        // Example of matched code: ```
        // a[l]=new o.Texture(e,new o.Rectangle(s+(t[l][0]+i)*(n+2*s),s+(t[l][1]+r)*(n+2*s),n,n))}))
        // ```
        // See https://api.pixijs.io/@pixi/core/PIXI/Texture.html
        var rectangle_init_regex = /(\w+\[\w+\])\s*=\s*new\s*(\w+)\.Texture\((\w+),\s*new\s*\w+.Rectangle\(([^,]+),([^,]+),([^,]+),([^,]+)\)\)/;
        let rectangle_init = rectangle_init_regex.exec(loopBody);
        if (!rectangle_init) return;
        let [_$2, target, argPixi, argBaseTexture, argRectX, argRectY, argRectWidth, argRectHeight] = rectangle_init;
        loopBody = (`
          // argBaseTexture is the texture loaded with ?animated - now we have to slice it up into individual frames
          
          let texture = new ${argPixi}.Texture(
            ${argBaseTexture},
            new ${argPixi}.Rectangle(${argRectX}, ${argRectY}, ${argRectWidth}, ${argRectHeight})
          );

          let base_tex_is_ghost = (
            ${argBaseTexture}?.resource?.url &&
            ${argBaseTexture}.resource.url.indexOf('ghost') !== -1
          );
          
          let { frames, delay } = base_tex_is_ghost
            ? ${b64Recode(res.ghostAnimMeta || {})}
            : ${b64Recode(res.skinAnimMeta || {})};
            
          // textures which don't have the '.resource.url' key are unrelated to skins, bail on animation.
          if (${argBaseTexture}?.resource?.url === undefined) {
            frames = 0;
            delay = 1;
          }
          let scale = base_tex_is_ghost ? 512 : 1024;

          // If there's multiple frames, slice them up and stick them on the texture for later use.
          // If not, the next replacement below will bail when it doesn't find the 'tetrioPlusAnimatedArray' key.
          if (frames > 1) {
            texture.tetrioPlusAnimatedArray = [];
            // use a long unique name for i here to avoid conflicting with any values named 'i' in the minified code
            for (let iteration_value = 0; iteration_value < frames; iteration_value++) {
              texture.tetrioPlusIsGhost = base_tex_is_ghost;
              texture.tetrioPlusAnimatedArray.push(new ${argPixi}.Texture(
                ${argBaseTexture},
                new ${argPixi}.Rectangle(
                  ${argRectX} + (iteration_value%16) * scale, // 16 frames per row is hardcoded in the import process
                  ${argRectY} + Math.floor(iteration_value/16) * scale,
                  ${argRectWidth},
                  ${argRectHeight}
                )
              ));
            }
          }

          ${target} = texture;
        `);
        match = true;
        return prefix + loopBody + '}';
      });
      if (!match) {
        console.warn('Advanced skin loader hooks broke (1/?)');
        return;
      }

      // Replace sprites with animated sprites
      // Example of matched code: ```
      // wang24":p=l.assets[yp()].textures[s][Fp[i]||255]}const c=new o.Sprite(p)
      // ```
      // Formatted with context: ```
      // generate: function (n, s, i = 255, r = 1, a = {}) {
      //   let l = kp[n];
      //   if (l || (n = 'tetrio', l = kp.tetrio), !l.assets[yp()].loaded) return l.assets[yp()].loading ||
      //   t(n),
      //   e(n, s, i, r, a);
      //   let p = o.Texture.WHITE;
      //   switch (l.assets[yp()].textures.format) {
      //     // regular format skins (5 rows of 2 blocks = 10 (possibly?))
      //     case '10':
      //       p = l.assets[yp()].textures[s];
      //       break;
      //     // connected format skins (4*6 connection variants per block type = 24)
      //     // we only care about these ones because we've forced loading connected skins
      //     // (in source/content/connected-skins.js)
      //     case 'wang24':
      //       p = l.assets[yp()].textures[s][Fp[i] || 255]
      //   }
      //   const c = new o.Sprite(p);
      //   return c.width = vo(Bp.x) * r,
      //   c.height = vo(Bp.x) * r,
      //   c
      // },
      // ```
      var regex = /(wang24[\S\s]{0,50}(.)\s*=\s*\w+\.assets\[.+?\].textures[\S\s]{0,50})new (\w+).Sprite\(\2\)/g;
      var match = 0;
      source = source.replace(regex, ($, pre, texVar, pixiVar) => {
        match += 1;
        return pre + (`
          (() => {
            if (!${texVar}.tetrioPlusAnimatedArray) // Bail on non-tetrioplus-animated skin
              return new ${pixiVar}.Sprite(${texVar});

            let { frames, delay } = ${texVar}.tetrioPlusIsGhost
              ? ${b64Recode(res.ghostAnimMeta || {})}
              : ${b64Recode(res.skinAnimMeta || {})};

            let sprite = new ${pixiVar}.AnimatedSprite(${texVar}.tetrioPlusAnimatedArray);
            sprite.animationSpeed = 1/delay;

            let is_first_frame = true;
            function spriteFrameIndexLoop() {
              let targetFrame = window.__tetrioPlusAdvSkinLoader.manualControl
                ? Math.floor(window.__tetrioPlusAdvSkinLoader.frame) % frames
                : Math.floor(((${pixiVar}.Ticker.shared.lastTime/1000) * 60 / delay) % frames);
              sprite.gotoAndStop(targetFrame);

              // once sprite.parent.parent disappears, the sprite has been removed from the overall scene tree.
              // it probably won't ever be used again, so we need to stop ticking it so it can be garbage collected.
              // it can also take a frame before the sprite has been _added_ to the scene tree, so wait for at least
              // one frame first.
              if (is_first_frame || (sprite.parent && sprite.parent.parent))
                requestAnimationFrame(spriteFrameIndexLoop);
              is_first_frame = false;
            }
            spriteFrameIndexLoop();
            return sprite;
          })()
        `);
      });
      if (match != 2) {
        console.warn('Advanced skin loader hooks broke (2/?)');
        return;
      }
      finalSource = source;
    } finally {
      callback({
        type: 'text/javascript',
        data: finalSource,
        encoding: 'text'
      });
    }
  }
})
