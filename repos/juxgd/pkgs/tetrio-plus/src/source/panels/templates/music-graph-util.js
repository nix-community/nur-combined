export const version = '0.22.2';

export function makeRootNode(config={}) {
  return {
    "id": 0,
    "type": "root",
    "name": "root",
    "audio": null,
    "background": null,
    "backgroundLayer": 0,
    "backgroundArea": 'background',
    "audioStart": 0,
    "audioEnd": 0,
    "triggers": [],
    "hidden": false,
    "effects": {
      "volume": 1,
      "speed": 1
    },
    "x": 0,
    "y": 0,
    ...config
  };
}

let idIncr = 1;
export function makeNode(config={}) {
  let id = config.id ? config.id : idIncr;
  idIncr = id+1;
  delete config.id;

  return {
    "id": id,
    "type": "normal",
    "name": `new node ${id}`,
    "audio": null,
    "background": null,
    "backgroundLayer": 0,
    "backgroundArea": 'background',
    "audioStart": 0,
    "audioEnd": 0,
    "triggers": [],
    "hidden": false,
    "effects": {
      "volume": 1,
      "speed": 1
    },
    "x": 0,
    "y": 0,
    ...config
  };
}

export function makeTrigger(config={}) {
  return {
    "mode": "goto",
    "event": "node-end",
    "predicateExpression": "",
    "timePassedDuration": 0,
    "target": 0,
    "dispatchEvent": "",
    "dispatchExpression": "",
    "setVariable": "",
    "setExpression": "",
    "crossfade": false,
    "preserveLocation": false,
    "crossfadeDuration": 1,
    "locationMultiplier": 1,
    "anchor": {
      "origin": {
        "x": 100,
        "y": 60
      },
      "target": {
        "x": 100,
        "y": 0
      }
    },
    ...config
  }
}
