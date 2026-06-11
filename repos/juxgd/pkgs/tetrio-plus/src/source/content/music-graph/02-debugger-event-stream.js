musicGraph(musicGraph => {
  // Event stream for the music graph debugger
  let port = null;
  let portConnected = false;
  function reconnect() {
    if (port) port.disconnect();

    // console.log("[TETR.IO PLUS] Music graph attempting debugger connection");
    port = browser.runtime.connect({
      name: 'music-graph-event-stream'
    });
    portConnected = false;

    let reconnTimeout = setTimeout(() => {
      // console.log("[TETR.IO PLUS] Music graph attempting reconnection");
      reconnect();
    }, 10000);

    port.onDisconnect.addListener(() => {
      console.log("[TETR.IO PLUS] Music graph debugger disconnected");
      port = null;
      portConnected = false;
      clearTimeout(reconnTimeout);
      setTimeout(() => reconnect(), 5000);
    });

    port.onMessage.addListener(async (msg) => {
      if (msg.type == 'spawn') {
        if (!musicGraph.graph[msg.sourceId]) return;
        let node = new musicGraph.Node();
        musicGraph.nodes.push(node);
        node.setSource(musicGraph.graph[msg.sourceId]);
        console.log('[TETR.IO PLUS] Music graph debugger spawned node', node);
      }
      if (msg.type == 'kill') {
        for (let node of musicGraph.nodes)
          if (node.id == msg.instanceId) {
            node.destroy();
            console.log("[TETR.IO PLUS] Music graph debugger destroyed node", node);
          }
      }
      if (msg.type == 'event') {
        musicGraph.dispatchEvent(msg.event, msg.value);
        console.log('[TETR.IO PLUS] Music graph debugger simulated event', msg.event, msg.value);
      }
      if (msg.type == 'hello') {
        console.log("[TETR.IO PLUS] Music graph debugger connected");
        portConnected = true;
        clearTimeout(reconnTimeout);
        // Catch the debugger up to the existing state...
        sendDebugEvent('reset', null);
        for (let node of musicGraph.nodes) {
          sendDebugEvent('node-created', {
            instanceId: node.id
          });
          sendDebugEvent('node-source-set', {
            instanceId: node.id,
            sourceId: node.source.id,
            lastSourceId: null
          });
          for (let [name, value] of Object.entries(node.variables)) {
            sendDebugEvent('node-set-variable', {
              instanceId: node.id,
              sourceId: node.source.id,
              variable: name,
              value: value
            });
          }
        }
      }
      if (msg.type == 'reload') {
        console.log("[TETR.IO PLUS] RELOADING MUSIC GRAPH");

        try {
          // Clean up old graph...
          port.disconnect();
          port = null;
          let resurrections = [];
          for (let node of musicGraph.nodes) {
            resurrections.push({
              id: node.id,
              sourceId: node.source.id,
              time: node.currentTime,
              variables: node.variables,
              children: node.children.map(child => child.id)
            });
            musicGraph.cleanup.push(() => node.destroy());
          }
          for (let handler of musicGraph.cleanup)
            handler();

          // Start new graph and copy what nodes we can
          let newGraphData = await musicGraph.initializeMusicGraph(false);
          for (let {id, sourceId, time, variables, children} of resurrections) {
            let source = newGraphData.graph[sourceId];
            if (!source) continue;
            let node = new newGraphData.Node();
            Object.assign(node.variables, variables);
            setTimeout(() => {
              // wait until all nodes are spawned so that child references populate correctly
              node.children = children
                .map(childId => newGraphData.nodes.filter(node => node.id == childId)[0])
                .filter(e => e);
            });
            newGraphData.nodes.push(node);
            node.setSource(source, time, 0, false, true);
          }
        } catch(ex) {
          alert("Failed to reload music graph: " + ex);
          console.error(ex);
        }
      }
    });
  }
  reconnect();

  let hardEvents = 0;
  let softEvents = 0;
  const softLimit = musicGraph.musicGraphReportedEventRateLimit;
  const hardLimit = musicGraph.musicGraphHardEventRateLimit;

  let resetThrottle = setInterval(() => {
    if (port && portConnected) {
      port.postMessage({
        type: 'event',
        name: 'eventsPerSecond',
        eventsPerSecond: hardEvents,
        warning: softEvents >= softLimit
      });
    }
    hardEvents = 0;
    softEvents = 0;
  }, 1000);
  musicGraph.cleanup.push(() => clearInterval(resetThrottle));

  let alerted = false;
  /**
   * Sends an event to the debugger
   * @param {String} name the name of the event
   * @param {Object} data per-event-defined data for the event
   * @param {Boolean} ratelimitEvent if events count towards the ratelimit
   */
  function sendDebugEvent(name, data=null, ratelimitEvent=false) {
    // Hard limit = kill graph immediately
    hardEvents++;
    if (hardEvents > hardLimit && musicGraph.nodes.length > 0) {
      for (let node of musicGraph.nodes.slice())
        node.destroy();
      if (!alerted) {
        alerted = true;
        alert(
          '[TETR.IO PLUS] Music graph event count above ' + hardLimit + ' per second' +
          ', graph automatically terminated to avoid freezing the game. Check your ' +
          'graph for performance issues. You can raise this limit in the ' +
          'Music Graph\'s global config section.'
        );
      };
    }

    if (ratelimitEvent) {
      // Soft limit = drop events
      softEvents += 1;
      if (softEvents > softLimit)
        return;
    }

    if (!port || !portConnected) return;
    port.postMessage({ type: 'event', name, data });
  }
  musicGraph.sendDebugEvent = sendDebugEvent;
});
