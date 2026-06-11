import { events, eventValueExtendedModes, eventHasTarget, eventType } from '../../events.js';
import { clipboard } from '../../clipboard.js';

export default {
  props: ['nodes'],
  computed: {
    nodesById() {
      let map = new Map();
      for (let node of this.nodes)
        map.set(node.id, node);
      return map;
    }
  },
  methods: {
    getNodeById(id) {
      return this.nodesById.get(id);
    },
    getNodeFromElem(elem) {
      if (!elem) return null;
      let nodeId = +elem.getAttribute('node-id');
      return this.getNodeById(nodeId);
    },
    getLinks(node, triggers) {
      return triggers.map((trigger, i) => {
        let target = this.getNodeById(trigger.target);
        if (!target) target = { id: -1, x: node.x, y: node.y };

        let label = trigger.event;
        if (eventType(trigger.event).mode == 'custom')
          label = '🌐' + label;
        if (eventValueExtendedModes[trigger.event])
          label += ` ${trigger.predicateExpression}`;
        label += ' ' + trigger.mode;
        if (trigger.mode == 'dispatch') {
          label += ' ' + trigger.dispatchEvent;
          if (trigger.dispatchExpression.trim().length > 0)
            label += ` (${trigger.dispatchExpression})`;
        }
        if (trigger.mode == 'set')
          label += ` ${trigger.setVariable} = ${trigger.setExpression}`;

        let targetType = 'target';
        if (trigger.target == node.id)
          targetType = 'self-target';
        if (!eventHasTarget[trigger.mode])
          targetType = 'no-target';

        let x1 = node.x + trigger.anchor.origin.x;
        let y1 = node.y + trigger.anchor.origin.y;
        let x2 = target.x + trigger.anchor.target.x;
        let y2 = target.y + trigger.anchor.target.y;

        let startCap = null;
        let endCap = 'arrow';

        // average relative position of anchors to their parents
        let relX = ((x1 - node.x) + (x2 - target.x))/2 * 1/200;
        let relY = ((y1 - node.y) + (y2 - target.y))/2 * 1/60;

        let textAnchor = 'start';
        if (relX < 2/3) textAnchor = 'middle';
        if (relX < 1/3) textAnchor = 'end';

        let textBaseline = relY < 0.5 ? 'baseline' : 'hanging';
        if (targetType != 'target')
          textBaseline = 'middle';

        // calculated later if not overriden.
        let translateX = null;
        let translateY = null;
        let textX = null;
        let textY = null;

        // Add offset from side to determine position of non-target node ends
        if (targetType != 'target') {
          let side = null;
          if (trigger.anchor.origin.y <= 10) side = 'top';
          if (trigger.anchor.origin.y >= 50) side = 'bottom';
          if (trigger.anchor.origin.x <= 10) side = 'left';
          if (trigger.anchor.origin.x >= 190) side = 'right';
          switch (side) {
            default:
            case 'top':
              x2 = x1;
              y2 = y1 - 50;
              relX = (x2 - node.x)/200;
              relY = ((y1 - node.y) + (y2 - target.y))/2 * 1/60;
              textY = y2 - 20;
              break;

            case 'bottom':
              x2 = x1;
              y2 = y1 + 50;
              relX = (x2 - node.x)/200;
              relY = ((y1 - node.y) + (y2 - target.y))/2 * 1/60;
              textY = y2 + 20;
              break;

            case 'left':
              y2 = y1;
              x2 = x1 - 50;
              relX = ((x1 - node.x) + (x2 - target.x))/2 * 1/200;
              relY = (y2 - node.y)/60;
              textX = x2 - 15;
              translateY = 0;
              break;

            case 'right':
              y2 = y1;
              x2 = x1 + 50;
              relX = ((x1 - node.x) + (x2 - target.x))/2 * 1/200;
              relY = (y2 - node.y)/60;
              textX = x2 + 15;
              translateY = 0;
              break;
          }
          startCap = 'arrow';
          endCap = 'dot';
        }

        if (translateX == null)
          translateX = relX < 1/3 ? -10 : relX > 2/3 ? 10 : 0;

        if (translateY == null)
          translateY = relY < 0.5 ? -5 : 5;

        if (textX === null)
          textX = (x2 + x1)/2 + translateX;

        if (textY === null)
          textY = (y2 + y1)/2 + translateY;

        if (trigger.mode == 'fork') {
          if (startCap == 'arrow') startCap = 'arrow-outline';
          if (endCap == 'arrow') endCap = 'arrow-outline';
        }

        if (trigger.mode == 'random') {
          startCap = null;
          endCap = '?';
        }

        if (trigger.mode == 'kill') {
          startCap = null;
          endCap = 'x';
        }

        if (trigger.mode == 'dispatch') {
          startCap = null;
          endCap = 'global';
        }

        if (trigger.mode == 'set') {
          startCap = null;
          endCap = '=';
        }

        return {
          i, trigger, targetType,
          label, startCap, endCap,
          x1, y1, x2, y2,
          relX, relY,
          textX, textY,
          textBaseline,
          textAnchor
        };
      });
    },
    getTargetedNodeElemFromTriggerElem(handle) {
      let node = this.getNodeFromElem(handle);

      if (this.getHandleTypeFromElem(handle) == 'origin')
        return this.getNodeElemFromNode(node);

      let trigger = this.getTriggerFromElem(handle);
      let target = this.getNodeById(trigger.target);
      return this.getNodeElemFromNode(target);
    },
    getTriggerFromElem(handleElem) {
      let node = this.getNodeFromElem(handleElem);
      let trigId = handleElem.getAttribute('trigger-index');
      let trigger = node.triggers[trigId];
      return trigger;
    },
    getHandleTypeFromElem(handleElem) {
      return handleElem.classList.contains('origin') ? 'origin' : 'target';
    },
    getNodeElemFromNode(node) {
      if (!node) return null;
      return document.querySelector(`.node[node-id="${node.id}"]`);
    },
    isSelected(node) {
      return clipboard.selected.indexOf(node) != -1
    }
  }
}
