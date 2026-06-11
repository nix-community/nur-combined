(async () => {
  let touches = [];
  let config = null;
  let keypresses = {
    hardDrop: new Set(),
    softDrop: new Set(),
    moveLeft: new Set(),
    moveRight: new Set(),
    rotateCW: new Set(),
    rotateCCW: new Set(),
    rotate180: new Set(),
    hold: new Set(),
    exit: new Set(),
    retry: new Set(),
    fullscreen: new Set(),
    enter: new Set(),
    hide: new Set()
  }
  let buttons = [];

  console.log("Awaiting config");
  await new Promise(res => {
    window.addEventListener("touchControlConfig", event => {
      config = JSON.parse(event.detail);
      res();
    }, { once: true });
    window.dispatchEvent(new CustomEvent("getTouchControlConfig"));
  });
  console.log("Got config", config);

  if (config.mode != 'touchpad') {
    config.keys.forEach((config, i) => {
      let { x, y, w, h, behavior, bind } = config;
      let button = document.createElement('div');
      button.classList.add('touch-button');
      button.classList.add('touch-bind-' + bind);
      button.innerText = bind;
      button.style.setProperty('--x', x + 'vw');
      button.style.setProperty('--y', y + 'vh');
      button.style.setProperty('--width', w + 'vw');
      button.style.setProperty('--height', h + 'vh');
      button.setAttribute('data-button-id', i);
      document.body.appendChild(button);

      function updateVisual() {
        let numDown = [...keypresses[bind]].filter(press => {
          return press.endsWith('button-' + i)
        }).length;
        button.classList.toggle('active', numDown > 0);
      }

      buttons.push({
        id: i,
        element: button,
        behavior,
        setDown(touchId) {
          setKey(bind, 'touch-' + touchId + '-button-' + i, true);
          updateVisual();
        },
        setUp(touchId) {
          setKey(bind, 'touch-' + touchId + '-button-' + i, false);
          updateVisual();
        }
      });
    });
  }

  function updateTouchElements(touchObj) {
    if (touchObj.origin) {
      touchObj.origin.style.left = touchObj.originX + 'px';
      touchObj.origin.style.top = touchObj.originY + 'px';
    }
    if (touchObj.indicator) {
      touchObj.indicator.style.left = touchObj.x + 'px';
      touchObj.indicator.style.top = touchObj.y + 'px';
    }
  }

  function addTouch(evt) {
    for (let touch of evt.changedTouches) {
      let button = null;
      let buttonsDown = [];

      if (config.mode != 'touchpad') {
        for (let buttonEl of document.elementsFromPoint(touch.pageX, touch.pageY)) {
          if (!buttonEl.classList.contains('touch-button')) continue;
          button = buttons[buttonEl.getAttribute('data-button-id')]
          buttonsDown.push(button);
          button.setDown(touch.identifier);
        }
      }

      let origin = null, indicator = null;
      if (config.mode != 'keys') {
        origin = document.createElement('div');
        origin.classList.add('touch-indicator');
        origin.classList.add('touch-origin');
        origin.style.setProperty('--deadzone', config.deadzone + 'px');
        document.body.appendChild(origin);

        indicator = document.createElement('div');
        indicator.classList.add('touch-indicator');
        indicator.classList.add('touch-position');
        document.body.appendChild(indicator);
      }


      let touchObj = {
        originX: touch.pageX,
        originY: touch.pageY,
        origin: origin,
        indicator: indicator,
        x: touch.pageX,
        y: touch.pageY,
        identifier: touch.identifier,
        side: touch.pageX < window.innerWidth/2 ? 'left' : 'right',
        touch: touch,
        buttonsDown
      };

      touches.push(touchObj);
      updateTouchElements(touchObj);
    }
  }

  function removeTouch(evt) {
    for (let touch of touches) {
      let remove = ([...evt.changedTouches].some(changedTouch =>
        touch.identifier == changedTouch.identifier
      ));
      if (remove) {
        touches.splice(touches.indexOf(touch), 1);
        if (touch.origin) touch.origin.remove();
        if (touch.indicator) touch.indicator.remove();

        for (let button of touch.buttonsDown)
          button.setUp(touch.identifier);

        if (touch.side == 'left') {
          setKey(config.binding.L_up, 'touch-' + touch.identifier + '-pad-left-up', false);
          setKey(config.binding.L_down, 'touch-' + touch.identifier + '-pad-left-down', false);
          setKey(config.binding.L_left, 'touch-' + touch.identifier + '-pad-left-left', false);
          setKey(config.binding.L_right, 'touch-' + touch.identifier + '-pad-left-right', false);
        } else {
          setKey(config.binding.R_up, 'touch-' + touch.identifier + '-pad-right-up', false);
          setKey(config.binding.R_down, 'touch-' + touch.identifier + '-pad-right-down', false);
          setKey(config.binding.R_left, 'touch-' + touch.identifier + '-pad-right-left', false);
          setKey(config.binding.R_right, 'touch-' + touch.identifier + '-pad-right-right', false);
        }
      }
    }
  }

  function moveTouch(evt) {
    for (let changedTouch of [...evt.changedTouches]) {
      for (let touch of touches) {
        if (touch.identifier != changedTouch.identifier)
          continue;
        touch.x = changedTouch.pageX;
        touch.y = changedTouch.pageY;
        updateTouchElements(touch);

        if (config.mode != 'touchpad') {
          let buttonsDown = document.elementsFromPoint(touch.x, touch.y)
            .filter(buttonEl => buttonEl.classList.contains('touch-button'))
            .map(buttonEl => buttons[buttonEl.getAttribute('data-button-id')])

          for (let button of buttonsDown) { // Add new buttons
            if (touch.buttonsDown.indexOf(button) == -1) {
              if (button.behavior == 'tap') continue;
              button.setDown(touch.identifier);
              touch.buttonsDown.push(button);
            }
          }

          for (let button of touch.buttonsDown) { // Remove old buttons
            if (buttonsDown.indexOf(button) == -1) {
              button.setUp(touch.identifier);
              touch.buttonsDown.splice(touch.buttonsDown.indexOf(button), 1)
            }
          }
        }

        if (config.mode != 'keys') {
          if (touch.side == 'left') {
            setKey(config.binding.L_up, 'touch-' + touch.identifier + '-pad-left-up', touch.y < touch.originY - config.deadzone);
            setKey(config.binding.L_down, 'touch-' + touch.identifier + '-pad-left-down', touch.y > touch.originY + config.deadzone);
            setKey(config.binding.L_left, 'touch-' + touch.identifier + '-pad-left-left', touch.x < touch.originX - config.deadzone);
            setKey(config.binding.L_right, 'touch-' + touch.identifier + '-pad-left-right', touch.x > touch.originX + config.deadzone);
          } else {
            setKey(config.binding.R_up, 'touch-' + touch.identifier + '-pad-right-up', touch.y < touch.originY - config.deadzone);
            setKey(config.binding.R_down, 'touch-' + touch.identifier + '-pad-right-down', touch.y > touch.originY + config.deadzone);
            setKey(config.binding.R_left, 'touch-' + touch.identifier + '-pad-right-left', touch.x < touch.originX - config.deadzone);
            setKey(config.binding.R_right, 'touch-' + touch.identifier + '-pad-right-right', touch.x > touch.originX + config.deadzone);
          }
        }
      }
    }
  }

  function getKeymap() {
    switch (window.keyMap.controls.style) {
      case 'guideline': return {
        moveLeft: ["ARROWLEFT", "LEFT", "NUMPAD4"],
        moveRight: ["ARROWRIGHT", "RIGHT", "NUMPAD6"],
        softDrop: ["ARROWDOWN", "DOWN", "NUMPAD2"],
        hardDrop: ["SPACE", "NUMPAD8"],
        rotateCCW: ["CONTROL", "CONTROLLEFT", "Z", "KEYZ", "NUMPAD3", "NUMPAD7"],
        rotateCW: ["ARROWUP", "UP", "X", "KEYX", "NUMPAD1", "NUMPAD5", "NUMPAD9"],
        rotate180: ["A", "KEYA"],
        hold: ["SHIFT", "SHIFTLEFT", "C", "KEYC", "NUMPAD0"],
        exit: ["ESCAPE"],
        retry: ["R", "KEYR"],
        chat: ["T", "KEYT"],
        target1: ["1", "DIGIT1"],
        target2: ["2", "DIGIT2"],
        target3: ["3", "DIGIT3"],
        target4: ["4", "DIGIT4"],
        menuUp: ["W", "KEYW", "ARROWUP", "UP"],
        menuDown: ["S", "KEYS", "ARROWDOWN", "DOWN"],
        menuLeft: ["A", "KEYA", "ARROWLEFT", "LEFT"],
        menuRight: ["D", "KEYD", "ARROWRIGHT", "RIGHT"],
        menuBack: ["ESCAPE", "BACKSPACE"],
        menuConfirm: ["ENTER", "NUMPADENTER", "SPACE"],
        openSocial: ["TAB"],
      };
      case 'wasd': return {
        moveLeft: ["A", "KEYA", "NUMPAD4"],
        moveRight: ["D", "KEYD", "NUMPAD6"],
        softDrop: ["W", "KEYW", "NUMPAD8"],
        hardDrop: ["S", "KEYS", "NUMPAD5"],
        rotateCCW: ["ARROWLEFT", "LEFT", "NUMPAD7"],
        rotateCW: ["ARROWRIGHT", "RIGHT", "NUMPAD9"],
        rotate180: ["ARROWUP", "UP", "NUMPAD2"],
        hold: ["SHIFT", "SHIFTLEFT", "NUMPADENTER"],
        exit: ["ESCAPE"],
        retry: ["R", "KEYR"],
        chat: ["T", "KEYT"],
        target1: ["1", "DIGIT1"],
        target2: ["2", "DIGIT2"],
        target3: ["3", "DIGIT3"],
        target4: ["4", "DIGIT4"],
        menuUp: ["W", "KEYW", "ARROWUP", "UP"],
        menuDown: ["S", "KEYS", "ARROWDOWN", "DOWN"],
        menuLeft: ["A", "KEYA", "ARROWLEFT", "LEFT"],
        menuRight: ["D", "KEYD", "ARROWRIGHT", "RIGHT"],
        menuBack: ["ESCAPE", "BACKSPACE"],
        menuConfirm: ["ENTER", "NUMPADENTER", "SPACE"],
        openSocial: ["TAB"],
      };
      case 'custom': return window.keyMap.controls.custom;
    }
  }

  let hidden = false;
  function setKey(key, presserId, pressed) {
    if (!keypresses[key]) return;
    if (pressed && !keypresses[key].has(presserId)) {
      if (keypresses[key].size == 0) {
        switch (key) {
          case 'hide':
            hidden = !hidden;
            document.body.classList.toggle('tetrio-plus-hide-touch-controls', hidden);
            break;

          case 'fullscreen':
            document.body.requestFullscreen();
            break;

          case 'enter':
            document.activeElement.dispatchEvent(new KeyboardEvent('keydown', {
              bubbles: true,
              code: 'Enter',
              key: 'Enter',
              keyCode: 13
            }));
            break;

          default:
            if (key.startsWith('literal-')) {
              // todo: check how safe this is before doing rest of implementation
              // document.body.dispatchEvent(new KeyboardEvent('keydown', {
              //   bubbles: true,
              //   code: key.slice('literal-'.length);
              // }));
            } else if (getKeymap()[key]) {
              let evt = new KeyboardEvent('keydown', {
                bubbles: true,
                code: getKeymap()[key][0] // global exposed from hook
              });
              document.body.dispatchEvent(evt);
            } else {
              console.warn('[TETR.IO PLUS] Touch controls: unknown key: ' + key);
            }
            break;
        }
      }
      keypresses[key].add(presserId);
    } else if (!pressed && keypresses[key].has(presserId)) {
      keypresses[key].delete(presserId);
      if (keypresses[key].size == 0) {
        switch (key) {
          case 'fullscreen':
          case 'hide':
            break;

          case 'enter':
            document.activeElement.dispatchEvent(new KeyboardEvent('keyup', {
              bubbles: true,
              code: 'Enter',
              key: 'Enter',
              keyCode: 13
            }));
            break;

          default:
            let evt = new KeyboardEvent('keyup', {
              bubbles: true,
              code: getKeymap()[key][0] // global exposed from hook
            });
            document.body.dispatchEvent(evt);
            break;
        }
      }
    }
  }

  window.keypresses = keypresses;

  window.addEventListener("touchstart", addTouch);
  window.addEventListener("touchend", removeTouch);
  window.addEventListener("touchcancel", removeTouch);
  window.addEventListener("touchmove", moveTouch);
})();
