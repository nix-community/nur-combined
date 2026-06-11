/*
  This has to be an injected script and not a content script because
  DOM events appear to stringify objects passed to them only for content
  scripts, and I need to call a function on an event's detail object
*/
(async () => {
  [...document.getElementsByClassName('tetrio-plus-osd')].forEach(c => c.remove());

  const { iconSet, baseIconURL } = await new Promise(res => {
    // some kinda race condition on electron,
    // retry firing 'getBaseIconURL' to avoid it.
    let interval = setInterval(() => {
      window.dispatchEvent(new CustomEvent("getBaseIconURL"));
    }, 1000);
    window.addEventListener(
      "baseIconURL",
      evt => {
        clearInterval(interval);
        // json stringify/parse to prevent
        // `Permission denied to access property "then"`
        // even though you can send objects through
        res(JSON.parse(evt.detail));
      },
      { once: true }
    );
  });

  let osds = [];
  function createOSD() {
    let osd = document.createElement('div');
    osd.classList.toggle('tetrio-plus-osd', true);
    osd.classList.toggle('icon-set-' + iconSet, true);
    document.body.appendChild(osd);

    let index = 0;

    let buttons = [];
    let buttonMap = {};
    function button(name, tetrioName) {
      let elem = document.createElement('div');
      elem.classList.toggle('tetrio-plus-osd-key', true);
      elem.classList.toggle(name, true);
      elem.style.gridArea = name;

      let icon = `url("${baseIconURL}icon-${tetrioName}.png")`;
      elem.style.setProperty('background-image', icon);
      elem.setActive = function(active) {
        if (iconSet == 'old') {
          elem.classList.toggle('active', active);
        } else {
          let suffix = active ? '-pressed' : '';
          let icon = `url("${baseIconURL}icon-${tetrioName}${suffix}.png")`;
          elem.style.setProperty('background-image', icon);
        }
      }

      elem.setActive(false);
      osd.appendChild(elem);
      buttons.push(elem);
      buttonMap[tetrioName] = elem;
    }

    button('left', 'moveLeft');
    button('right', 'moveRight');
    button('softdrop', 'softDrop');
    button('harddrop', 'hardDrop');
    button('spin-cw', 'rotateCW');
    button('spin-ccw', 'rotateCCW');
    button('spin-180', 'rotate180');
    button('hold', 'hold');

    let handleContainer = document.createElement('div');
    handleContainer.classList.toggle('tetrio-plus-osd-handle-container');
    osd.appendChild(handleContainer);

    let resizeHandle = document.createElement('div');
    resizeHandle.classList.toggle('tetrio-plus-osd-resize-handle');
    handleContainer.appendChild(resizeHandle);

    if (iconSet == 'old') {
      resizeHandle.innerText = '🡦';
    } else {
      let resizeIcon = `url("${baseIconURL}resize.png")`;
      resizeHandle.style.setProperty('background-image', resizeIcon);
    }

    // too lazy to write hooks back to browser storage from an injected script
    const fixedAspect = 3.125;
    const minWidth = 150;
    const minHeight = minWidth / fixedAspect;

    let x = 0;
    let y = 0;
    let w = 0;
    let h = 0;

    function getSaved(i) {
      let config = [];
      try { config = JSON.parse(localStorage.__tetrioPlusOSD); } catch(ex) {}
      return config[index] || { x: 40, y: 40+i*minHeight*2, w: minWidth*2, h: minHeight*2 }
    }

    function reindex() {
      index = [
        ...document.querySelectorAll('.tetrio-plus-osd:not(.disabled)'),
        ...document.querySelectorAll('.tetrio-plus-osd.disabled')
      ].indexOf(osd);
      let { x: _x, y: _y, w: _w, h: _h } = getSaved(index);
      x = _x; y = _y; w = _w; h = _h;
      resize();
    }
    reindex();

    function resize() {
      let _x = x, _y = y, _w = w, _h = h;
      if (_w < minWidth) _w = minWidth;
      if (_h < minHeight) _h = minHeight;

      osd.style.left = _x + 'px';
      osd.style.top = _y + 'px';
      osd.style.width = _w + 'px';
      osd.style.height = _h + 'px';

      let fontSize = Math.min(Math.floor(_w/6), Math.floor(_h/2)) - 4;
      for (let button of buttons) {
        button.style.fontSize = fontSize + 'px';
      }
    }
    resize();

    let dragging = false;
    let resizing = false;
    let lastMouseX = 0, lastMouseY = 0;
    osd.addEventListener('mousedown', evt => {
      lastMouseX = evt.clientX;
      lastMouseY = evt.clientY;
      dragging = true;
    });
    resizeHandle.addEventListener('mousedown', evt => {
      lastMouseX = evt.clientX;
      lastMouseY = evt.clientY;
      resizing = true;
    });
    document.body.addEventListener('mousemove', evt => {
      if (resizing) {
        w += evt.clientX - lastMouseX;
        h += evt.clientY - lastMouseY;
        if (evt.shiftKey) h = w / fixedAspect;
        resize();
      } else if (dragging) {
        x += evt.clientX - lastMouseX;
        y += evt.clientY - lastMouseY;
        resize();
      }
      lastMouseX = evt.clientX;
      lastMouseY = evt.clientY;
    });
    document.body.addEventListener('mouseup', evt => {
      dragging = false;
      resizing = false;
      if (x < 0) x = 0;
      if (y < 0) y = 0;
      if (w < minWidth) w = minWidth;
      if (h < minHeight) h = minHeight;
      if (x > window.innerWidth - w) x = window.innerWidth - w;
      if (y > window.innerHeight - h) y = window.innerHeight - h;
      if (w > window.innerWidth) w = window.innerWidth;
      if (h > window.innerHeight) w = window.innerHeight;

      let config = [];
      try { config = JSON.parse(localStorage.__tetrioPlusOSD); } catch(ex) {}
      config[index] = { x, y, w, h };
      localStorage.__tetrioPlusOSD = JSON.stringify(config);
      resize();
    });

    let the_osd = {
      osd,
      index,
      buttonMap,
      buttons,
      reenable() {
        if (osd.classList.contains('disabled')) {
          osd.classList.remove('disabled');
          for (let osd of osds)
            osd.reindex();
        }
      },
      destroy() {
        osd.remove();

        // Generally once one is destroyed, all of them are going to be destroyed.
        // This isn't certain, so disable it instead until more events are received.
        for (let osd of osds)
          osd.osd.classList.add('disabled');

        let i = osds.indexOf(the_osd);
        if (i != -1) osds.splice(i, 1);
        for (let osd of osds)
          osd.reindex();
      },
      reindex
    };
    osds.push(the_osd);
    for (let osd of osds)
      osd.reindex();
    return the_osd;
  }

  document.addEventListener('tetrio-plus-on-game', evt => {
    let instance = evt.detail.instance;
    // If the event source type is a socket, its someone else's board
    // (Singleplayer, replay, and own boards in multiplayer have no sockets)
    // This has been seen as 'keyboard' (own board), 'replay' (everyone in a replay), and 'socket' (remote players)
    // Seems to fire twice per board for 'replay', as well.
    if (instance._type == 'socket') return;

    // limit number of active OSDs
    if ([...document.querySelectorAll('.tetrio-plus-osd')].length > 10) return;
    
    // defer creating OSD for replays until key events actually come in
    // looks like e.g. viewing a replay stats page creates event sources,
    // presumably to get information necessary for summarizing the replay,
    // but doesn't actually "play" them back
    let osd = null;
    if (instance._type == 'keyboard')
      osd = createOSD();
    
    // other keys seen: 'exit' 'retry'
    instance.On('keydown', (evt) => {
      if (!osd) osd = createOSD();
      osd.reenable();
      // this isn't technically correct since the exit can be aborted by
      // failing to hold it long enough, but in general by the time an exit
      // is started, the player intends to finish it. Better than having
      // old OSDs hang around.
      if (evt.data.key == 'exit') osd.destroy();
      osd.buttonMap[evt.data.key]?.setActive(true)
    });
    instance.On('keyup', (evt) => {
      if (!osd) osd = createOSD();
      osd.reenable();
      osd.buttonMap[evt.data.key]?.setActive(false);
    });

    let original_destroy = instance.Destroy.bind(instance);
    instance.Destroy = function(...args) {
      console.log("event source destroyed");
      if (osd) osd.destroy();
      original_destroy(...args);
    }
  });
})().catch(ex => console.error(ex));
