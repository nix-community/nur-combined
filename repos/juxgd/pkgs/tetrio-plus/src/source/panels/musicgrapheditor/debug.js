const debug = {
  liveInstances: [],
  recentTriggerFires: {}, // node -> array
  eventsPerSecond: 0,
  eventsPerSecondWarning: false,
  port: null
};
export default debug;

browser.runtime.onConnect.addListener(port => {
  if (port.name != 'music-graph-event-stream') return;
  if (debug.port) {
    port.disconnect();
    return;
  }
  console.log("Music graph instance connected");
  debug.port = port;
  debug.eventsPerSecond = 0;
  debug.eventsPerSecondWarning = false;
  port.onMessage.addListener(handleDebugMessage);
  port.onDisconnect.addListener(() => {
    console.log("Music graph instance disconnected");
    debug.liveInstances = [];
    debug.recentTriggerFires = {};
    debug.port = null;
  });
  setTimeout(() => {
    debug.port.postMessage({ type: 'hello' });
  });
});

setInterval(() => {
  for (let key of Object.keys(debug.recentTriggerFires)) {
    debug.recentTriggerFires[key] = debug.recentTriggerFires[key].filter(el=>{
      el.age = Date.now() - el.date;
      return el.age < el.maxAge;
    });
  }
}, 16);

function handleDebugMessage(msg) {
  if (msg.type != 'event') return;
  
  // console.log(msg.type, msg.name, Object.entries(msg.data).map(e => `${e[0]}: ${e[1]}`).join(', '));
  switch (msg.name) {
    case 'eventsPerSecond': {
      debug.eventsPerSecond = msg.eventsPerSecond;
      debug.eventsPerSecondWarning = msg.warning;
      break;
    }

    case 'reset': {
      debug.liveInstances = [];
      debug.recentTriggerFires = {};
      break;
    }

    case 'node-created': {
      debug.liveInstances.push({
        ...msg.data,
        sourceId: null,
        variables: {},
        recentTriggers: []
      });
      break;
    }

    case 'node-destroyed': {
      let i = debug.liveInstances.findIndex(({ instanceId }) => {
        return instanceId == msg.data.instanceId;
      });
      if (i == -1) break;
      debug.liveInstances.splice(i, 1);
      break;
    }

    case 'node-source-set': {
      for (let instance of debug.liveInstances) {
        if (instance.instanceId == msg.data.instanceId) {
          if (isFinite(msg.data.lastSourceId) && (msg.data.lastSourceId != instance.sourceId)) {
            // Ensure forks are animated
            instance.sourceId = msg.data.lastSourceId;
            setTimeout(() => instance.sourceId = msg.data.sourceId, 20);
          } else {
            instance.sourceId = msg.data.sourceId;
          }
          // msg.data.lastSourceId
          break;
        }
      }
      break;
    }

    case 'node-set-variable': {
      for (let instance  of debug.liveInstances) {
        if (instance.instanceId == msg.data.instanceId) {
          Vue.set(instance.variables, msg.data.variable, msg.data.value);
          break;
        }
      }
      break;
    }

    case 'node-run-trigger': {
      if (!debug.recentTriggerFires[msg.data.sourceId])
        Vue.set(debug.recentTriggerFires, msg.data.sourceId, []);

      let recent = debug.recentTriggerFires[msg.data.sourceId];
      if (recent.length > 10) recent.splice(0, 1);
      recent.push({
        instance: msg.data.instanceId,
        trigger: msg.data.trigger,
        success: msg.data.success,
        values: msg.data.values,
        date: Date.now(),
        age: 0,
        maxAge: 500
      });
      break;
    }

  }
}