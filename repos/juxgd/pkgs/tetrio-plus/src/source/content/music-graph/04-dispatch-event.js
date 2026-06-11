musicGraph(graph => {
  let {
    Node,
    nodes,
    cleanup,
    sendDebugEvent,
    globalVariables,
    ExpVal
  } = graph;
  let eventLimit = 20;
  let recentEvents = [];
  let eventLastFired = {};
  let recording = { active: false, buffer: [] };

  let f8menu = document.getElementById('devbuildid');
  let f8menuActive = false;
  graph.f8menuEnabled = true;
  if (!f8menu) {
    console.log("[TETR.IO PLUS] Can't find '#devbuildid'?")
  } else {
    let div = document.createElement('div');
    cleanup.push(() => div.remove());
    div.style.fontFamily = 'monospace';
    div.id = 'tetrio-plus-music-graph-debug';
    div.innerHTML = `
      TETR.IO PLUS music graph debug<br>
      <div id="tetrio_plus_music_graph_disabled">
        Music graph debugger disabled via API
      </div>
      <div class="tetrio-plus-music-graph-debug-output">
        -- Recent events --
        <div id="tetrio_plus_music_graph_events">
        </div>
        -- Global variables --
        <div id="tetrio_plus_music_graph_variables">
        </div>
        -- Nodes --
        <pre id="tetrio_plus_music_graph_nodes" style="margin: 0px">
        </pre>
      </div>

      <style>
        #tetrio-plus-music-graph-debug:not(.disabled) > #tetrio_plus_music_graph_disabled {
          display: none;
        }
        #tetrio-plus-music-graph-debug.disabled > .tetrio-plus-music-graph-debug-output {
          display: none;
        }
        #tetrio_plus_music_graph_events span {
          min-width: 300px;
          border: 1px solid #AAA;
          margin-right: 2px;
          display: inline-block;
        }
      </style>
      <button id="tetrio_plus_record_replay" style="pointer-events: all">record</button>
    `;
    f8menu.parentNode.insertBefore(div, f8menu.nextSibling.nextSibling);
    
    let container = document.getElementById('tetrio-plus-music-graph-debug');
    let events = document.getElementById('tetrio_plus_music_graph_events');
    let variables = document.getElementById('tetrio_plus_music_graph_variables');
    let nodesel = document.getElementById('tetrio_plus_music_graph_nodes');
    
    let record = document.getElementById('tetrio_plus_record_replay');
    record.addEventListener('click', () => {
      if (!recording.active) {
        recording.active = true;
        recording.buffer.length = 0;
      } else {
        recording.active = false;
        let data = { __schema: 'tetrio-plus-music-graph-replay', events: recording.buffer };
        let blob = new Blob([JSON.stringify(data)], { type: 'application/json' });
        let a = document.createElement('a');
        a.style.display = 'block';
        a.style.color = 'cyan';
        a.style['pointer-events'] = 'all';
        a.innerText = `download replay (${Math.round(blob.size/1024)}KiB)`;
        a.href = URL.createObjectURL(blob);
        a.download = `tetrio-plus-music-graph-replay_${recording.buffer.length}-events_${new Date().toISOString()}.json`;
        container.appendChild(a);
      }
    });

    setInterval(() => {
      container.classList.toggle('disabled', !graph.f8menuEnabled);
      f8menuActive = graph.f8menuEnabled && !f8menu.parentNode.classList.contains('off');
      if (!f8menuActive) return;
      
      record.innerText = recording.active
        ? `Stop recording (${recording.buffer.length} events...)`
        : `Record music graph events to file`;

      events.innerHTML = ``;
      for (let i = recentEvents.length-1; i >= recentEvents.length-eventLimit; i--) {
        let event = recentEvents[i];
        if (!event) continue;

        let span = document.createElement('span');
        span.innerText = event;
        let delay = Date.now() - eventLastFired[event];

        if (delay < 1000) {
          let opacity = 1 - Math.sqrt(delay / 1000);
          let color = '#FFA500' + Math.floor(opacity * 120).toString(16).padStart(2, '0');
          span.style.backgroundColor = color;
        }

        let div = document.createElement('div');
        let pct = delay < 1000 ? (1 - delay/1000) * 100 : 0;
        Object.assign(div.style, {
          width: '300px',
          height: '2px',
          background: `linear-gradient(to right, #FF0000 ${pct}%, #770000 ${pct}%)`
        });
        span.appendChild(div);

        events.appendChild(span);
      }

      let recent = 0;
      for (let event of recentEvents)
        if (Date.now() - eventLastFired[event] < 1000)
          recent += 1;
      if (recent > eventLimit)
        eventLimit = Math.min(recent, 100);

      variables.innerHTML = ``;
      for (let [key, value] of Object.entries(globalVariables)) {
        let span = document.createElement('span');
        span.innerText = `${key}: ${value}`;
        span.style.marginRight = '4px';
        variables.appendChild(span);
      }

      nodesel.innerText = nodes.map(node => node.toString()).join('\n');
    }, 30);
  }

  /**
   * Dispatches a global event to the music graph,
   * running the relevent triggers on all nodes.
   * @param eventName the name of the event to dispatch.
   * @param value an object map of variables that are overlaid while the event is active. If a single number is passed, it's used as the `$` key ({ $: value })
   */
  graph.dispatchEvent = function dispatchEvent(eventName, value) {
    value = value ?? {};
    if (typeof value == 'number')
      value = { $: value };

    if (f8menuActive) {
      function advancedRound(value) {
        if ((value > 0 && value < 0.0001) || (value > 0.9999 && value < 1))
          return +value.toExponential(3);
        return +value.toFixed(4);
      }
      let valueKeys = Object.keys(value);
      let dataString = valueKeys.length == 0
        ? null
        : valueKeys.length == 1 && valueKeys[0] == '$'
          ? value.$
          : Object.entries(value).map(([k,v]) => `${k}=${advancedRound(v)}`).join(', ');
      let str = dataString != null
        ? `${eventName} (${dataString})`
        : eventName;

      let index = recentEvents.indexOf(str);
      if (index !== -1)
        recentEvents.splice(index, 1);

      recentEvents.push(str);
      eventLastFired[str] = Date.now();

      if (recentEvents.length > eventLimit*2)
        recentEvents = recentEvents.slice(-eventLimit);
    }
    if (recording.active) {
      recording.buffer.push({ real_time: Date.now(), audio_time: graph.audioContext.currentTime, event: eventName, value: value });
    }


    for (let nodeSrc of Object.values(graph.graph)) {
      for (let trigger of nodeSrc.triggers) {
        if (trigger.mode == 'create' && trigger.event == eventName) {
          if (nodes.length >= 100) {
            console.error("[TETR.IO PLUS] Music graph: Too many nodes, aborting create.");
            break;
          }
          let node = new Node();
          if (node.testTrigger(trigger, value)) {
            nodes.push(node);
            node.setSource(nodeSrc);
          }
        }
      }
    }

    for (let node of nodes.slice()) // slice since events could add or remove nodes
      for (let trigger of node.source.triggers)
        if (trigger.mode != 'create' && trigger.event == eventName)
          node.runTrigger(trigger, value, 0);
  }
});
