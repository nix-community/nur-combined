musicGraph(({ dispatchEvent, cleanup }) => {
    let elements = [];
    for (let menu of document.querySelectorAll("[data-menuview]")) {
      elements.push({
        type: `menu-${menu.getAttribute('data-menuview')}`,
        element: menu
      });
    }
    for (let id of ['forfeit', 'retry', 'replay', 'spectate']) {
      elements.push({
        type: `hud-${id}`,
        element: document.getElementById(id)
      });
    }

    for (let { type, element } of elements) {
      let wasHidden = true;

      let observer = new MutationObserver(mutations => {
        for (let mut of mutations) {
          let hidden = mut.target.classList.contains("hidden");
          if (wasHidden == hidden) continue;
          wasHidden = hidden;
          dispatchEvent(`${type}-${hidden ? 'close' : 'open'}`, null);
        }
      });
      cleanup.push(() => observer.disconnect());

      observer.observe(element, {
        attributes: true,
        attributeFilter: ['class'],
        childList: false,
        CharacterData: false
      });
    }

    // note: comments probably outdated, but heuristic itself still works.
    function locationHeuristic(size, spatialization) {
      if (size == 'tiny') return 'enemy'; // If tiny, always an enemy
      // Solo spatialization is exactly 0
      // Duel spatialization is -0.3499...
      if (spatialization <= 0) return 'player';
      // Duel enemy spatialization is 0.4499...
      return 'enemy';
    }

    let controller = new AbortController();
    cleanup.push(() => controller.abort());

    document.addEventListener('tetrio-plus-fx', evt => {
      try {
      let type = locationHeuristic(evt.detail.boardSize, evt.detail.spatialization);
      let values = { $board: evt.detail.board_id };
      let { name, args } = evt.detail;
      switch (name) {
        case 'countdown_stride':
          var count = ["GO!", "set", "ready"].indexOf(args[0])
          dispatchEvent(`fx-countdown-${count}`, values);
          dispatchEvent(`text-countdown-${count}`, values); // backwards compat
          break;
        case 'countdown':
          var count = args[0] == 'GO!' ? 0 : parseInt(args[0]);
          dispatchEvent(`fx-countdown`, { $: count, ...values });
          dispatchEvent(`text-countdown-${count}`, values); // backwards compat
          break;
        case 'clear':
          let level = [
            'NONE', 'SINGLE', 'DOUBLE', 'TRIPLE', 'QUAD', 'PENTA', 'HEXA',
            'HEPTA', 'OCTA', 'ENNEA', 'DECA', 'HENDECA', 'DODECA', 'TRIADECA',
            'TESSARADECA', 'PENTEDECA', 'HEXADECA', 'HEPTADECA', 'OCTADECA',
            'ENNEADECA', 'EICOSA', 'KAGARIS'
          ].indexOf(args[0]);
          dispatchEvent(`fx-line-clear`, { $: level, ...values })
          dispatchEvent(`fx-line-clear-${type}`, { $: level, ...values })
          break;
        case 'clutch':
          dispatchEvent(`fx-clutch`, values);
          dispatchEvent(`fx-clutch-${type}`, values);
          break;
        case 'zenlevel':
          dispatchEvent(`fx-zen-levelup`, values);
          break;
        case 'levelup':
          dispatchEvent(`fx-master-levelup`, values);
          break;
        case 'combo':
          dispatchEvent(`fx-combo`, { $: parseInt(args[0]), ...values })
          dispatchEvent(`fx-combo-${type}`, { $: parseInt(args[0]), ...values })
          break;
        case 'tspin':
          let piece = args[0].toLowerCase()[0];
          dispatchEvent(`fx-${piece}-spin`, values);
          dispatchEvent(`fx-${piece}-spin-${type}`, values);

          // backwards compat
          dispatchEvent(`text-${piece}-spin`, values);
          dispatchEvent(`text-any-spin`, values);
          break;
        case 'timeleft':
          if (args[0].endsWith('PLAYERS LEFT'))
            dispatchEvent(`fx-${parseInt(args[0])}-players-left`, values);
          if (args[0].endsWith('S LEFT'))
            dispatchEvent(`fx-${parseInt(args[0])}-seconds-left`, values);
          break;
        case 'popup_offence': // (lines sent)
          dispatchEvent(`fx-offense`, { $: args[0], ...values });
          dispatchEvent(`fx-offense-${type}`, { $: args[0], ...values });
          dispatchEvent(`text-spike`, { $: args[0], ...values }); // backwards compat
          break;
        case 'popup_defense': // (lines blocked)
          dispatchEvent(`fx-defense`, { $: args[0], ...values });
          dispatchEvent(`fx-defense-${type}`, { $: args[0], ...values });
          dispatchEvent(`text-spike`, { $: args[0], ...values }); // backwards compat
          break;
      }
      } catch(ex) { console.error(ex)}
    }, { signal: controller.signal });

    // for "in-game" sound effects associated with a board
    document.addEventListener('tetrio-plus-actionsound', evt => {
      let name = evt.detail.name;
      let type = locationHeuristic(evt.detail.boardSize, evt.detail.spatialization);
      dispatchEvent(`sfx-${name}`, { $board: evt.detail.board_id });
      dispatchEvent(`sfx-${name}-${type}`, { $board: evt.detail.board_id });
    }, { signal: controller.signal });

    // for all sound effects, including menu sfx and those duplicated from "in-game" sfx
    document.addEventListener('tetrio-plus-globalsound', evt => {
      let name = evt.detail.name;
      dispatchEvent(`sfx-${name}-global`, {
        $volume: evt.detail.volume,
        $pan: evt.detail.spatialization
      });
    }, { signal: controller.signal });

    document.addEventListener('tetrio-plus-actionheight', evt => {
      // The 'height' is actually the *unfilled* portion of the board,
      // but we want the filled portion to pass for the event
      let height = 40 - evt.detail.height;
      let type = locationHeuristic(evt.detail.boardSize, evt.detail.spatialization);
      dispatchEvent(`board-height`, { $: height, $board: evt.detail.board_id });
      dispatchEvent(`board-height-${type}`, { $: height, $board: evt.detail.board_id });
    }, { signal: controller.signal });

    // generic event receiver, currently only used from board height-related
    // board identification hooks.
    document.addEventListener('tetrio-plus-event', evt => {
      let data = {};
      if (typeof evt.detail.$ == 'number')
        data.$ = evt.detail.$;
      if (typeof evt.detail.board_id == 'number')
        data.$board = evt.detail.board_id;

      dispatchEvent(evt.detail.event, data);

      if (evt.detail.boardSize && typeof evt.detail.spatialization == 'number') {
        let type = locationHeuristic(evt.detail.boardSize, evt.detail.spatialization);
        dispatchEvent(evt.detail.event + '-' + type, data);
      }
    }, { signal: controller.signal });
  });
