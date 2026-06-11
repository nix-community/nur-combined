musicGraph(musicGraph => {
  const {
    nodes,
    globalVariables,
    audioContext: context,
    imageCache,
    sendDebugEvent,
    graph,
    audioBuffers,
    getGlobalVolume,
    backgroundsEnabled,
    musicGraphNodeLimit,
    ExpVal
  } = musicGraph;

  /**
   * To achieve good audio playback, audio events are scheduled
   * SYNC_DElAY milliseconds into the future. Rather than waiting
   * once the event fires, the event is instead scheduled early
   * and the new audio node state is delayed for some number
   * of milliseconds.
   * this value (30ms) is only used for node-end, random-target
   * uses a 15ms variant. (TODO: document why)
   */
  const SYNC_DELAY = 30;
  const SHORT_SYNC_DELAY = 15;
  const initTime = Date.now();
  let nonce = 0;

  const gameCanvas = document.getElementById('pixi');
  gameCanvas.style.backgroundPosition = 'center';
  gameCanvas.style.backgroundSize = 'cover';

  const backgroundContainer = document.createElement('div');
  backgroundContainer.id = "tetrio-plus-background-layers";
  backgroundContainer.style.position = 'fixed';
  backgroundContainer.style.zIndex = -1;

  const foregroundContainer = document.createElement('div');
  foregroundContainer.id = "tetrio-plus-foreground-layers";
  foregroundContainer.style.position = 'fixed';
  foregroundContainer.style.zIndex = 1;

  for (let container of [backgroundContainer, foregroundContainer]) {
    container.style.width = '100vw';
    container.style.height = '100vh';
    container.style.top = '0px';
    container.style.left = '0px';
    container.style.pointerEvents = 'none';
    document.body.appendChild(container);
  }

  /**
   * If the nodes in the music graphs are like classes, then the Node is
   * an instance of one of those classes. It has internal state and uses
   * triggers from the graph node classes to fork or goto other graph nodes.
   */
  musicGraph.Node = class Node {
    constructor() {
      // console.log("Created new node");
      this.id = nonce++;
      sendDebugEvent('node-created', {
        instanceId: this.id
      });
      this.audio = null; // AudioBufferSourceNode
      this.volume = null; // GainNode
      this.timeouts = [];
      this.startedAt = null;
      this.children = [];
      this.variables = {};
      this.background = {
        playing: true,
        playbackRate: 1,
        x: 0,
        y: 0,
        width: 100,
        height: 100,
        opacity: 1,
        currentElement: null
      };
    }

    static recalculateBackground() {
      if (!backgroundsEnabled) return;

      let justRemoved = new Set([...backgroundContainer.children, ...foregroundContainer.children]);
      for (let container of [backgroundContainer, foregroundContainer]) {
        while (container.lastChild) {
          container.lastChild.__tetrioplus_image_cache.push(container.lastChild);
          container.lastChild.remove();
        }
      }

      for (let node of nodes)
        node.background.currentElement = null;

      let sortedNodes = nodes
        .filter(node => node.source?.background)
        .sort((a, b) => {
          a = a.source.backgroundLayer;
          b = b.source.backgroundLayer;
          return a == b ? 0 : (a > b ? -1 : 1);
        })
        .reverse()
        .map(node => {
          let cache = imageCache[node.source.id];
          let el = cache.ready.length > 0
            ? cache.ready.pop()
            : cache.base.cloneNode();
          el.__tetrioplus_image_cache = cache.ready;
          node.background.currentElement = el;
          el.style.opacity = 1;
          return [node, el];
        });

      backgroundContainer.append(...sortedNodes.filter(([node, _el]) => node.source.backgroundArea == 'background').map(([_node, el]) => el));
      foregroundContainer.append(...sortedNodes.filter(([node, _el]) => node.source.backgroundArea == 'foreground').map(([_node, el]) => el));

      for (let [node, el] of sortedNodes) {
        if (node.background.playing && el.play) {
          let start = Date.now()
          el.play();//.then(() => console.log(`[TETR.IO PLUS] Node took ${Date.now() - start}ms to play`));
        }
        el.playbackRate = node.background.playbackRate;
        el.style.left = `${node.background.x}vw`;
        el.style.top = `${node.background.y}vh`;
        el.style.width = `${node.background.width}vw`;
        el.style.height = `${node.background.height}vh`;
        el.style.opacity = node.background.opacity;
        justRemoved.delete(el);
      }

      for (let el of justRemoved)
        if (el instanceof HTMLVideoElement)
          el.currentTime = 0;

      gameCanvas.style.backgroundImage = null;
    }

    setSource(source, startTime=0, audioDelay=0, crossfade=false, suppressEmptyNodeEnd=false, parentSourceId=null) {
      if (this.destroyed) return;
      sendDebugEvent('node-source-set', {
        instanceId: this.id,
        sourceId: source.id,
        lastSourceId: this.source?.id || parentSourceId
      });
      if (source.singleInstance) {
        if (nodes.some(node => node.source?.id == source.id)) {
          this.destroy();
          return;
        }
      }
      this.source = source;
      Node.recalculateBackground();

      for (let timeout of this.timeouts)
        clearTimeout(timeout);
      this.timeouts.length = 0;

      this.restartAudio(startTime, crossfade, audioDelay, suppressEmptyNodeEnd);

      for (let trigger of this.source.triggers) {
        switch (trigger.event) {
          case 'time-passed':
            this.timeouts.push(setTimeout(
              () => this.runTrigger(trigger, null, SYNC_DELAY/1000),
              trigger.timePassedDuration*1000 - SYNC_DELAY + audioDelay*1000
            ));
            break;
          case 'repeating-time-passed':
            this.timeouts.push(setTimeout(
              () => {
                this.timeouts.push(setInterval(
                  () => this.runTrigger(trigger, null, SYNC_DELAY/1000),
                  trigger.timePassedDuration*1000
                ));
              },
              SYNC_DELAY + audioDelay*1000
            ));
            break;
        }
      }
    }

    /**
     * @param startTime Where to start in the given audio buffer
     * @param crossfade Whether to use crossfade effects
     * @param audioDelay How long to wait before starting the new audio node
     *                   and stopping the old one.
     */
    restartAudio(startTime, crossfade=false, audioDelay=0, suppressEmptyNodeEnd=false) {
      this.startedAt = context.currentTime + audioDelay - startTime;
      if (this.destroyed) return;
      if (!this.source.audio) {
        if (!suppressEmptyNodeEnd)
          this.runTriggersByName('node-end', null);
        return;
      }

      let audioSource = context.createBufferSource();
      audioSource.buffer = audioBuffers[this.source.audio];

      audioSource.playbackRate.value = this.source.effects.speed;

      let gainNode = context.createGain();
      gainNode.gain.value = this.source.effects.volume * getGlobalVolume();

      if (this.audio) {
        if (!crossfade) {
          this.audio.stop(context.currentTime + audioDelay);
        } else {
          let oldAudio = this.audio;
          let oldVolume = this.volume;
          gainNode.gain.value = 0;

          let start = Date.now() + audioDelay;
          let end = start + crossfade * 1000 + audioDelay;
          let startVolOld = oldVolume.gain.value;

          let interval = setInterval(() => {
            let progress = 1 - (end - Date.now()) / (end - start);
            if (progress > 1) {
              clearInterval(interval);
              oldAudio.stop(context.currentTime + audioDelay);
              return;
            }

            oldVolume.gain.value = (1 - progress) * startVolOld;
            this.volume.gain.value = (
              progress *
              this.source.effects.volume *
              getGlobalVolume()
            );
          }, 16);
        }
      }

      audioSource.connect(gainNode).connect(context.destination);
      let start = startTime + this.source.audioStart;
      let duration = (
        (this.source.audioEnd || audioSource.buffer.duration) -
        this.source.audioStart
      ) - startTime;
      try {
        audioSource.start(context.currentTime + audioDelay, start, duration);
      } catch(ex) {
        audioSource.start(0, 0, 0);
        console.warn(ex);
      }

      this.timeouts.push(setTimeout(
        () => {
          if (this.audio != audioSource) return;
          this.runTriggersByName('node-end', null, SYNC_DELAY / 1000);
        },
        (duration * 1000) / this.source.effects.speed - SYNC_DELAY
      ));

      this.audio = audioSource;
      this.volume = gainNode;
    }

    get currentTime() {
      return context.currentTime - this.startedAt;
    }

    static _constrain(val, lower=0, upper=1) {
      if (isNaN(+val)) return 0;
      return Math.min(Math.max(val, lower), upper);
    }

    computedVariables(extra) {
      let node = this;
      return new Proxy({}, {
        get(_, prop) {
          if (prop.startsWith('#'))
            return globalVariables[prop];
          if (extra && prop in extra)
            return extra[prop];
          switch(prop) {
            case '$volume': return node.volume;
            case '$age': return node.currentTime;
            case '$time': return context.currentTime;
            case '$bg_x': return node.background.x;
            case '$bg_y': return node.background.y;
            case '$bg_width': return node.background.width;
            case '$bg_height': return node.background.height;
            case '$bg_opacity': return node.background.opacity;
            case '$bg_paused': return node.background.currentElement?.paused || 0;
            case '$bg_time': return node.background.currentElement?.currentTime || 0;
            case '$bg_playback_rate': return node.background.currentElement?.playbackRate || 1;
            default: return node.variables[prop];
          }
          if (prop in computed)
            return computed[prop];
          return node.variables[prop];
        },
        set(_, prop, value) {
          if (prop.startsWith('#')) {
            globalVariables[prop] = value;
            return true;
          }
          if (extra && prop in extra) {
            // extra is used for values that only exist during the event, meaning they're effectively write-only.
            // drop the write for now.
            // extra variables used by tetrio plus always start with $, but api users can set them to anything.
            return true;
          }

          switch (prop) {
            case '$volume': {
              node.volume = Node._constrain(value, 0, 1);
              return true;
            }
            case '$skin_manual_control': {
              document.dispatchEvent(new CustomEvent('tetrio-plus-set-skin-manual-control', { detail: value != 0 }));
              return true;
            }
            case '$skin_frame': {
              document.dispatchEvent(new CustomEvent('tetrio-plus-set-skin-frame', { detail: value }));
              return true;
            }
            case '$bg_x': {
              node.background.x = Node._constrain(value, -100, 100);
              node.background.currentElement.style.left = `${node.background.x}vw`;
              return true;
            }
            case '$bg_y': {
              node.background.y = Node._constrain(value, -100, 100);
              node.background.currentElement.style.top = `${node.background.y}vh`;
              return true;
            }
            case '$bg_width': {
              node.background.width = Node._constrain(value, 0, 100);
              node.background.currentElement.style.width = `${node.background.width}vw`;
              return true;
            }
            case '$bg_height': {
              node.background.height = Node._constrain(value, 0, 100);
              node.background.currentElement.style.height = `${node.background.height}vh`;
              return true;
            }
            case '$bg_opacity': {
              node.background.opacity = Node._constrain(value, 0, 1);
              node.background.currentElement.style.opacity = node.background.opacity;
              return true;
            }
            case '$bg_paused': {
              node.background.playing = !value;
              let video = node.background.currentElement;
              if (!(video instanceof HTMLVideoElement)) return true;
              if (node.background.playing) video.play(); else video.pause();
              return true;
            }
            case '$bg_time': {
              let video = node.background.currentElement;
              if (!(video instanceof HTMLVideoElement)) return true;
              let start = Date.now();
              video.addEventListener('seeked', () => {
                node.runTriggersByName('video-background-seeked', Date.now() - start);
              }, { once: true });
              video.currentTime = Node._constrain(value, 0, video.duration || Infinity);
              return true;
            }
            case '$bg_playback_rate': {
              node.background.playbackRate = value;
              let video = node.background.currentElement;
              if (!(video instanceof HTMLVideoElement)) return true;
              video.playbackRate = Node._constrain(val, 0, Infinity);
              return true;
            }
            default: {
              node.variables[prop] = value;
              return true;
            }
          }
        }
      });
    }

    destroy() {
      if (!this.destroyed) {
        sendDebugEvent('node-destroyed', {
          instanceId: this.id,
          sourceId: this.source?.id
        });
      }
      this.destroyed = true;

      if (this.audio) this.audio.stop();

      let index = nodes.indexOf(this);
      if (index !== -1) nodes.splice(index, 1);

      for (let timeout of this.timeouts)
        clearTimeout(timeout);

      for (let child of this.children)
        child.runTriggersByName('parent-node-destroyed', null);
      this.children.length = 0;

      Node.recalculateBackground();
    }

    runTriggersByName(name, values, audioDelay=0) {
      if (!this.source) return;
      for (let trigger of this.source.triggers)
        if (trigger.event == name)
          this.runTrigger(trigger, values, audioDelay);
    }

    testTrigger(trigger, values) {
      if (trigger.predicateExpression.trim().length > 0) {
        try {
          let context = this.computedVariables(values);
          let expValue = ExpVal.get(trigger.predicateExpression).evaluate(context);
          if (!expValue) return false;
        } catch(ex) {
          console.warn(`[TETR.IO PLUS] Music graph: error evaluating predicate ${trigger.predicateExpression}`, ex);
        }
      }

      return true;
    }

    runTrigger(trigger, values, audioDelay=0) {
      if (this.destroyed || !this.source) return;
      try {
        let result = this.testTrigger(trigger, values);
        sendDebugEvent('node-run-trigger', {
          instanceId: this.id,
          sourceId: this.source.id,
          success: result,
          trigger: this.source.triggers.indexOf(trigger),
          values: values
        }, true);
        if (!result) return false;

        let startTime = trigger.preserveLocation
          ? this.currentTime * trigger.locationMultiplier
          : 0;
        switch (trigger.mode) {
          case 'fork': {
            var src = graph[trigger.target];
            if (!src) {
              console.error("[TETR.IO PLUS] Unknown node #" + trigger.target);
              break;
            }
            if (nodes.length >= musicGraphNodeLimit) {
              throw new Error(
                "[TETR.IO PLUS] Music graph: Too many nodes (" + nodes.length +
                "), aborting fork. You can raise this limit in the Music " +
                "Graph's global config."
              );
            }
            var node = new Node();
            Object.assign(node.variables, this.variables);
            nodes.push(node);
            let crossfade = trigger.crossfade && trigger.crossfadeDuration;
            node.setSource(src, startTime, audioDelay, crossfade, false, this.source.id);
            Node.recalculateBackground();
            this.children.push(node);
            break;
          }
          case 'goto': {
            var src = graph[trigger.target];
            if (!src) {
              console.error("[TETR.IO PLUS] Unknown node #" + trigger.target);
              break;
            }
            let crossfade = trigger.crossfade && trigger.crossfadeDuration;
            this.setSource(src, startTime, audioDelay, crossfade);
            break;
          }
          case 'kill': {
            this.destroy();
            break;
          }
          case 'random': {
            let triggers = this.source.triggers.filter(trigger =>
              trigger.event == 'random-target' && trigger.mode != 'random'
            );
            if (triggers.length == 0) break;
            this.runTrigger(
              triggers[Math.floor(Math.random() * triggers.length)],
              null,
              SHORT_SYNC_DELAY/1000
            );
            break;
          }
          case 'dispatch': {
            let val = trigger.dispatchExpression.trim().length > 0
              ? ExpVal.get(trigger.dispatchExpression).evaluate(this.computedVariables(values))
              : null;
            musicGraph.dispatchEvent(trigger.dispatchEvent, val);
            break;
          }
          case 'set': {
            let computed = this.computedVariables(values);
            let val = ExpVal.get(trigger.setExpression).evaluate(computed);
            computed[ExpVal.substitute(trigger.setVariable, computed)] = val;
            sendDebugEvent('node-set-variable', {
              instanceId: this.id,
              sourceId: this.source.id,
              variable: trigger.setVariable,
              value: val
            });
            break;
          }
        }
      } catch(ex) {
        console.warn('[TETR.IO PLUS] Music graph: error running trigger', trigger, ex);
      }
    }

    toString() {
      let debug = ['Node ', this.source.name];
      for (let [key, val] of Object.entries(this.variables))
        debug.push(` ${key}=${val}`);
      for (let trigger of this.source.triggers) {
        debug.push('\n​ ​ ​ ​');
        debug.push(' ' + trigger.event);

        if (['repeating-time-passed', 'time-passed'].includes(trigger.event))
          debug.push(' ' + trigger.timePassedDuration + 's');

        debug.push(' ' + trigger.mode);

        if (trigger.mode == 'fork' || trigger.mode == 'goto')
          debug.push(' ' + (graph[trigger.target] || {}).name);

        if (trigger.mode == 'set')
          debug.push(` ${trigger.setVariable} = ${trigger.setExpression}`);

        if (trigger.mode == 'dispatch') {
          debug.push(' ' + trigger.dispatchEvent);
          if (trigger.dispatchExpression.trim().length > 0)
            debug.push(` (${trigger.dispatchExpression})`);
        }

        if (trigger.predicateExpression.trim().length > 0)
          debug.push(' if ' + trigger.predicateExpression);
      }
      return debug.join('');
    }
  }
});
