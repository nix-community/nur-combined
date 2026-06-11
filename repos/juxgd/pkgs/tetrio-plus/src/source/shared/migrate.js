var migrate = (() => {
  const migrations = [];

  function compare(version, target) {
    version = version.split('.').map(n => +n);
    target = target.split('.').map(n => +n);
    for (let i = 0; i < 3; i++) {
      if (version[i] > target[i]) return 1;
      if (version[i] < target[i]) return -1;
    }
    return 0;
  }

  /*
    v0.10.0 - Introduced migrations
    All this version adds is a version tag
  */
  migrations.push({
    version: '0.10.0',
    run: async dataSource => {
      await dataSource.set({ version: '0.10.0' });
    }
  });

  /*
    v0.12.0 - Music graph update
    Adds a bunch of new keys to the music graph
  */
  migrations.push({
    version: '0.12.0',
    run: async dataSource => {
      await dataSource.set({ version: '0.12.0' });

      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);

        let x = 0;
        for (let node of musicGraph) {
          node.x = (x += 30);
          node.y = 0;
          node.effects = { volume: 1, speed: 1 }
          for (let trigger of node.triggers) {
            trigger.anchor = {
              origin: { x: 100, y: 60 },
              target: { x: 100, y: 0 }
            }
            trigger.crossfade = false;
            trigger.crossfadeDuration = 1;
            trigger.locationMultiplier = 1;
          }
        }

        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  });


  /*
    v0.12.0 - Music editor update
    Redesigned the music editor and added overrides
  */
  migrations.push({
    version: '0.13.0',
    run: async dataSource => {
      await dataSource.set({ version: '0.13.0' });
      let { music } = await dataSource.get('music');
      if (!music) return;

      for (let song of music)
        song.override = null;
    }
  });

  /*
    v0.14.0 - TPSE integration update
    Added the 'useContentPack' URL-based loader.
  */
  migrations.push({
    version: '0.14.0',
    run: async dataSource => {
      await dataSource.set({
        version: '0.14.0',
        whitelistedLoaderDomains: [
          '# One protocol and domain per',
          '# line. https recommended.',
          'https://tetrio.team2xh.net',
          'https://you.have.fail'
        ]
      });
    }
  });

  /*
    v0.15.0 - Better:tm: skins update
    'skin' -> 'skinSvg'
  */
  migrations.push({
    version: '0.14.0',
    run: async dataSource => {
      await dataSource.set({
        version: '0.15.0',
        skin: null,
        skinSvg: await dataSource.get('skin')
      });
    }
  });

  /*
    v0.17.0 - Small music graph update + general bugfixes
    Added:
    - tetrioPlusEnabled
    - musicGraph[].audioStart
    - musicGraph[].audioEnd
  */
  migrations.push({
    version: '0.17.0',
    run: async dataSource => {
      await dataSource.set({
        version: '0.17.0',
        tetrioPlusEnabled: true
      });

      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);

        let x = 0;
        for (let node of musicGraph) {
          node.audioStart = 0;
          node.audioEnd = 0;
        }

        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  });

  /*
    v0.18.0 - Small music graph update + general bugfixes
    added:
    - musicGraph[].triggers[].dispatchEvent
    - musicGraph[].background
  */
  migrations.push({
    version: '0.18.0',
    run: async dataSource => {
      await dataSource.set({ version: '0.18.0' });

      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);
        for (let node of musicGraph) {
          node.background = null;
          for (let trigger of node.triggers) {
            trigger.dispatchEvent = '';
          }
        }
        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  });

  /*
    v0.18.2 - Partial update for new skin format
    Removed: skinSvg, skinPng, skinAnim, skinAnimMeta
    Added: skin, ghost
  */
  migrations.push({
    version: '0.18.2',
    run: async dataSource => {
      await dataSource.set({ version: '0.18.2' });
      let { skinSvg } = await dataSource.get(['skinSvg'])

      // TODO: Implement a real migration for this data
      // (importers are es6, migrate.js unfortunately isn't.)

      await dataSource.remove(['skinSvg', 'skinPng', 'skinAnim', 'skinAnimMeta'])

    }
  });

  /*
    v0.20.0 - More music graph stuff
    added:
    - musicGraph[].backgroundLayer
  */
  migrations.push({
    version: '0.20.0',
    run: async dataSource => {
      await dataSource.set({ version: '0.20.0' });

      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);
        for (let node of musicGraph) {
          node.backgroundLayer = 0;
        }
        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  });


  /*
    v0.21.0 - Even more music graph stuff
    added:
    - musicGraph[].triggers[].expression
    - musicGraph[].triggers[].variable
  */
  migrations.push({
    version: '0.21.0',
    run: async dataSource => {
      await dataSource.set({ version: '0.21.0' });

      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);
        for (let node of musicGraph) {
          for (let trigger of node.triggers) {
            trigger.expression = '';
            trigger.variable = '';
          }
        }
        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  });

  /*
    v0.20.1 - Music graph variables betterer

    + musicGraph[].triggers[].predicateExpression
    = musicGraph[].triggers[].value -> timePassedDuration or predicate
    = musicGraph[].triggers[].valueOperator -> predicate
    = musicGraph[].triggers[].expression -> setExpression, dispatchExpression
    = musicGraph[].triggers[].variable -> setVariable
  */
  migrations.push({
    version: '0.21.1',
    run: async dataSource => {
      await dataSource.set({ version: '0.21.1' });

      const eventValueExtendedModes = {
        'fx-countdown': true,
        'fx-offense-player': true,
        'fx-offense-enemy': true,
        'fx-defense-player': true,
        'fx-defense-enemy': true,
        'fx-combo-player': true,
        'fx-combo-enemy': true,
        'fx-line-clear-player': true,
        'fx-line-clear-enemy': true,
        'board-height-player': true,
        'board-height-enemy': true
      };

      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);
        for (let node of musicGraph) {
          for (let trigger of node.triggers) {
            trigger.timePassedDuration = (
              ['repeating-time-passed', 'time-passed'].includes(trigger.event)
                ? trigger.value
                : 0
            );
            trigger.predicateExpression = (
              eventValueExtendedModes[trigger.event] &&
              trigger.valueOperator != 'any'
            ) ? (`$ ${trigger.valueOperator} ${trigger.value}`) : "";
            trigger.dispatchExpression = trigger.mode == 'dispatch'
              ? trigger.expression
              : "";
            trigger.setExpression = trigger.mode == 'set'
              ? trigger.expression
              : "";
            trigger.setVariable = trigger.variable;

            delete trigger.valueOperator;
            delete trigger.value;
            delete trigger.expression;
            delete trigger.variable;
          }
        }
        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  });

  /*
    v0.21.3 - Slightly Better Backgrounds
    added:
    - backgrounds[].type
  */
  migrations.push({
    version: '0.21.3',
    run: async dataSource => {
      await dataSource.set({ version: '0.21.3' });
      let { backgrounds } = await dataSource.get('backgrounds');
      if (backgrounds)
        for (let bg of backgrounds)
          bg.type = 'image';
      await dataSource.set({ backgrounds });
    }
  });

  /*
    v0.23.4 - More music graph stuff
    + musicGraph[].singleInstance
  */
  migrations.push({
    version: '0.23.4',
    run: async dataSource => {
      await dataSource.set({ version: '0.23.4' });
      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);
        for (let node of musicGraph)
          node.singleInstance = false;
        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  });

  /*
    v0.23.8 - Winter compat patch
    + winterCompatEnabled
  */
  migrations.push({
    version: '0.23.8',
    run: async dataSource => {
      await dataSource.set({ version: '0.23.8' });
      let board = await dataSource.get('board');
      if (board) await dataSource.set({ winterCompatEnabled: false });
    }
  });

  /*
    v0.25.3 - Music graph foregrounds
    + musicGraph[].backgroundArea
  */
  migrations.push({
    version: '0.25.3',
    run: async dataSource => {
      await dataSource.set({ version: '0.25.3' });
      let { musicGraph: json } = await dataSource.get('musicGraph');
      if (json) {
        let musicGraph = JSON.parse(json);
        for (let node of musicGraph)
          node.backgroundArea = 'background';
        await dataSource.set({ musicGraph: JSON.stringify(musicGraph) });
      }
    }
  })
  
  /*
   v0.27.3 - TETR.IO beta v1.0.0 adds 'hidden' field to music
   + music[].metadata.hidden
  */
  migrations.push({
    version: '0.27.3',
    run: async dataSource => {
      await dataSource.set({ version: '0.27.3' });
      let { music } = await dataSource.get('music');
      if (music) {
        for (let song of music)
          song.metadata.hidden = false;
        await dataSource.set({ music });
      }
    }
  });
  
  /*
   v0.27.10 - TETR.IO beta β1.7.4  adds 'normalizeDb' field to music
   + music[].metadata.hidden
  */
  migrations.push({
    version: '0.27.10',
    run: async dataSource => {
      await dataSource.set({ version: '0.27.10' });
      let { music } = await dataSource.get('music');
      if (music) {
        for (let song of music)
          song.metadata.normalizeDb = 0;
        await dataSource.set({ music });
      }
    }
  });
  
  /*
    v0.28.0 - flattens double serialization of the music graph and touch controls.
    It's weird and more cumbersome to deal with in rust than it is in javascript.
    + JSON.deserialize(musicGraph)
    + JSON.deserialize(touchControlConfig)
  */
  migrations.push({
    version: '0.28.0',
    run: async dataSource => {
      await dataSource.set({ version: '0.28.0' });
      let { musicGraph, touchControlConfig } = await dataSource.get(['musicGraph', 'touchControlConfig']);
      if (musicGraph) await dataSource.set({ musicGraph: JSON.parse(musicGraph) });
      if (touchControlConfig) await dataSource.set({ touchControlConfig: JSON.parse(touchControlConfig) });
    }
  });

  return async function migrate(dataSource) {
    let { version: initialVersion} = await dataSource.get('version');
    if (!initialVersion) initialVersion = '0.0.0';

    for (let migration of migrations) {
      let { version } = await dataSource.get('version');
      if (!version) version = '0.0.0';
      let target = migration.version;

      // console.log("Testing migration", version, target, compare(version, target));
      if (compare(version, target) == -1) {
        // console.log("Running migration", migration);
        await migration.run(dataSource);
      }
    }

    return {
      from: initialVersion,
      to: (await dataSource.get('version')).version
    };
  }
})();


if (typeof module !== 'undefined')
  module.exports = migrate;
if (typeof window !== 'undefined')
  window.migrate = migrate;
