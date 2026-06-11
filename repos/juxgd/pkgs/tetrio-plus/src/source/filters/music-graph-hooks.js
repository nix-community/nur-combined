/*
*/
createRewriteFilter("Music graph hooks", "https://tetr.io/js/tetrio.js*", {
  enabledFor: async (storage, url) => {
    let res = await storage.get([
      'musicEnabled', 'musicGraphEnabled'
    ]);
    return res.musicEnabled && res.musicGraphEnabled;
  },
  onStop: async (storage, url, src, callback) => {
    try {
      // Written 2023-11-12
      // Music graph had changes. `playIngame` is gone. There's now two interesting functions:
      // big Play and little play. Big Play appears to be a per-board instance, wheras little
      // play is more global. Game sound effects are played through big Play which calls
      // little play. 'global' sound effects like menu/ui ones are played only through little play.
      // Update 2024-01-20:
      // little play was replaced with a new PlaySE function that seems to do the same thing,
      // though with the web audio api instead of howler.js

      src = `
        let musicGraphIDIncrement = 0;
        let musicGraphBoardHeightCache = {};

        setInterval(() => {
          for (let [key, value] of Object.entries(musicGraphBoardHeightCache)) {
            if (Date.now() > value.time + 250) {
              delete musicGraphBoardHeightCache[key];
              document.dispatchEvent(new CustomEvent('tetrio-plus-event', {
                detail: { event: 'board-gone', board_id: +key }
              }));
            }
          }
        }, 250);
      ` + src;

      // This regex matches the big Play function.
      // It takes three parameters: the name of the sound, then two mystery parameters.
      //
      // Also inside is a reference to something that contains an `IsLocal` field.
      // This is `true` when a board is actively being played from the client.
      // We would have used this for player/enemy detection, but it's _always_ false in replays.
      // Instead, we scavenged references to recalculate the old 'tiny'/'full' board sizes.
      // (These are coxPath (equivalent to old spatialization) and boardSizeObjectPath
      // (contains IsSmallBoard()/IsTinyBoard() methods))
      //
      // Additionally, we add code that inserts a unique ID on the per-board instance.
      // We track this code to assign external board IDs to events. The object we insert
      // this on is available through other paths in the other hooks below, as well.
      let bigPlay = /Play\((\w+),\s*(\w*)\s*=\s*\d,\s*(\w*)\s*=\s*\d,\s*(\w*)\s*=\s*\d\)\s*{[\S\s]+?(this\.self\.\w+\.IsLocal\(\))[\S\s]+?this\.self\.((\w+)\..{1,30}\.cox)/;
      let bigPlayMatch = bigPlay.exec(src);
      if (!bigPlayMatch) {
        console.error('Music graph hooks broken (bigPlay)');
        return;
      }
      let [_match, soundNameVar, unknown1Var, unknown2Var, unknown3Var, _isLocalInvocation, coxPath, boardSizeObjectPath] = bigPlayMatch;

      // This regex matches big Play for dispatching sound effects
      var match = false;
      src = src.replace(/Play\(\w+,\s*\w*\s*=\s*\d,\s*\w*\s*=\s*\d,\s*\w*\s*=\s*\d\)\s*{/, ($) => {
        match = true;
        return $ + (`
          let boardSize = (this.self.${boardSizeObjectPath}.IsTinyMode() || this.self.${boardSizeObjectPath}.IsSmallMode()) ? 'tiny' : 'full';
          if (!this.self.__tetrio_plus_board_id) {
            this.self.__tetrio_plus_board_id = ++musicGraphIDIncrement;
            document.dispatchEvent(new CustomEvent('tetrio-plus-event', {
              detail: {
                event: 'board-new',
                board_id: this.self.__tetrio_plus_board_id,
                boardSize: boardSize,
                spatialization: this.self.${coxPath}
              }
            }));
          }
          if (musicGraphBoardHeightCache[this.self.__tetrio_plus_board_id])
            musicGraphBoardHeightCache[this.self.__tetrio_plus_board_id].time = Date.now();
          document.dispatchEvent(new CustomEvent('tetrio-plus-actionsound', {
            detail: {
              name: ${soundNameVar},
              board_id: this.self.__tetrio_plus_board_id,
              boardSize: boardSize,
              spatialization: this.self.${coxPath}
            }
          }));
        `);
      });
      if (!match) {
        console.error('Music graph hooks broken (bigPlay2)');
      }



      var match = false;
      var rgx = /(fx\((\w+)\)\s*{\s*)return\s*(this\.effects\.get\(\w+\))/;
      src = src.replace(rgx, ($, functionHeader, fxNameArgumentVar, getInvocation) => {
        match = true;
        return functionHeader + (`
          let effect = ${getInvocation};

          // IsTinyMode and IsSmallMode are literally just right there in the code
          // very convenient
          let boardSize = (this.IsTinyMode() || this.IsSmallMode()) ? 'tiny' : 'full';
          let spatialization = this.ctx.${coxPath};
          if (!this.ctx.__tetrio_plus_board_id) {
            this.ctx.__tetrio_plus_board_id = ++musicGraphIDIncrement;
            document.dispatchEvent(new CustomEvent('tetrio-plus-event', {
              detail: {
                event: 'board-new',
                board_id: this.ctx.__tetrio_plus_board_id,
                boardSize: boardSize,
                spatialization: spatialization
              }
            }));
          }
          let board_id = this.ctx.__tetrio_plus_board_id;
          if (musicGraphBoardHeightCache[board_id])
            musicGraphBoardHeightCache[board_id].time = Date.now();




          // The effect map seems to be empty sometimes, leading to effect being null
          // (Maybe related to being tiny boards?). TETR.IO by default has an
          // \`return effect || <variable>\`, where <variable> was last seen in
          // the form of \`{ parent: undefined, options: undefined }\`. Thus,
          // should be fine to replace it with an empty object.
          let patched = Object.create(effect ? effect.__proto__ : {});
          Object.assign(patched, {
            ...effect,
            create(...args) {
              document.dispatchEvent(new CustomEvent('tetrio-plus-fx', {
                detail: {
                  name: ${fxNameArgumentVar},
                  board_id: board_id,
                  args: args,
                  boardSize: boardSize,
                  spatialization: spatialization
                }
              }));

              // NOTE:
              // After some investigation, it seems like the effects map might be per-board
              // and each fx carries a bit of internal state. Constantly recreating new fx
              // with 'effect.create.apply(this, args)' was causing some fx to appear repeatedly.
              // This current approach seems to work, but patching the fx list directly instead
              // of ad hoc on creation may be worth looking into.
              if (effect)
                effect.create.apply(effect, args);
            }
          });
          return patched /* implicit || after this, no semicolon */
        `);
      })
      if (!match) {
        console.error('Music graph hooks broken (fx)');
      }



      /**
       * This regex looks for a convenient "HighestLine" function to send off below.
       */
      let highestLinePath = /let\s*\w+\s*=\s*(\w+\.\w+\.HighestLine\(\))/.exec(src);
      if (!highestLinePath) {
        console.error('Music graph hooks broken (height 1/2)');
        return;
      }
      const highestLineCall = highestLinePath[1];

      /**
       * This regex hooks a convenient location for us to send off data from
       * variables gathered in other hooks
       */
      var match = false;
      var rgx = /(\w+)\.\w+\.IsServer\(\)\s*\|\|\s*\(\s*\w+\.\w+\.\w+\.stackdirty/;
      src = src.replace(rgx, ($, contextVar) => {
        match = true;
        return `
        let height = ${highestLineCall};
        let bso = ${contextVar}.${boardSizeObjectPath};

        if (!${contextVar}.__tetrio_plus_board_id) {
          ${contextVar}.__tetrio_plus_board_id = ++musicGraphIDIncrement;
          document.dispatchEvent(new CustomEvent('tetrio-plus-event', {
            detail: {
              event: 'board-new',
              board_id: ${contextVar}.__tetrio_plus_board_id,
              boardSize: (bso.IsTinyMode() || bso.IsSmallMode()) ? 'tiny' : 'full',
              spatialization: ${contextVar}.${coxPath}
            }
          }));
        }
        let board_id = ${contextVar}.__tetrio_plus_board_id;

        let last = musicGraphBoardHeightCache[board_id];
        if (last) last.time = Date.now();
        if (!last || (height != last.height)) {
          musicGraphBoardHeightCache[board_id] = { height, time: Date.now() };

          document.dispatchEvent(new CustomEvent('tetrio-plus-actionheight', {
            detail: {
              height,
              board_id,
              boardSize: (bso.IsTinyMode() || bso.IsSmallMode()) ? 'tiny' : 'full',
              spatialization: ${contextVar}.${coxPath}
            }
          }));
        }
        ` + $;
      });
      if (!match) {
        console.error('Music graph hooks broken (height 2/2)');
      }

      var match = false;
      var rgx = /SePlay:\s*function\s*\((\w+),\s*(\w+)\s*=\s*1,\s*(\w+)\s*=\s*0,\s*(\w+)\s*=\s*1\)\s*{/;
      src = src.replace(rgx, ($, a1, a2, a3, a4, a5) => {
        match = true;
        // a1 = sfx name
        // a2 = volume (0 to 1)
        // a3 = pan left/right (-1 to 1)
        // a4 = unknown
        // a5 = unknown
        return $ + `
          document.dispatchEvent(new CustomEvent('tetrio-plus-globalsound', {
            detail: {
              name: ${a1},
              volume: ${a2},
              spatialization: ${a3}
            }
          }));
        `;
      })
      if (!match) {
        console.error('Music graph hooks broken (globalSfx)');
      }
    } finally {
      callback({
        type: 'text/javascript',
        data: src,
        encoding: 'text'
      });
    }
  }
})
