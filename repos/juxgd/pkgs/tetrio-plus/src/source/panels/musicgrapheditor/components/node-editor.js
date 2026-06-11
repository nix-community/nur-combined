import TriggerEditor from './trigger-editor.js';
import NodeMusicEditor from './node-music-editor.js';
import * as clipboard from '../clipboard.js';
import { eventHasTarget } from '../events.js';
const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <fieldset :id="'node-' + node.id">
      <legend>
        <button @click="node.hidden = false" v-if="node.hidden == true">⮞</button>
        <button @click="node.hidden = true" v-else>⮟</button>
        <template v-if="node.type == 'root'">
          Root
        </template>
        <template v-else>
          <input type="text" v-model="node.name"/>
          <button @click="removeNode(node)" class="icon-button">❌</button>
          <button @click="copyNode(node)">Copy</button>
          <button @click="shiftNode(node, -1)" class="icon-button">🔼</button>
          <button @click="shiftNode(node, 1)" class="icon-button">🔽</button>
        </template>
      </legend>

      <div v-show="!node.hidden">
        <node-music-editor :node="node" @change="$emit('change')" />

        <div v-if="(reverseLinkLookupTable[node.id] || []).size > 0"
             class="section">
          Linked from
          <span v-for="link of reverseLinkLookupTable[node.id]" class="linkback">
            <a href="#" @click="focus(link)">{{ link.name }}</a>
          </span>
        </div>

        Triggers
        <div class="triggers section">
          <div class="trigger" v-for="(trigger, i) of node.triggers" :trigger-index="i">
            <trigger-editor
              :nodes="nodes"
              :node="node"
              :trigger="trigger"
              @focus="focus"
              @change="$emit('change')"
            />
          </div>
          <div class="paste-and-trigger-controls">
            <button @click="addTrigger(node)">
              New trigger
            </button>
            <button @click="pasteTrigger(node)" :disabled="!copiedTrigger">
              Paste trigger
            </button>
            <button @click="pasteNode(node)" :disabled="!copiedNode">
              Paste node here
            </button>
            <button @click="moveNode(node)" :disabled="!copiedNode">
              Move node here
            </button>
          </div>
        </div>
      </div>
    </fieldset>
  `,
  data: () => {
    return { clipboard }
  },
  props: ['nodes', 'node'],
  components: { NodeMusicEditor, TriggerEditor },
  computed: {
    reverseLinkLookupTable() {
      let links = {};

      for (let node of this.nodes) {
        for (let trigger of node.triggers) {
          if (trigger.target == node.id) continue;
          if (!eventHasTarget[trigger.mode]) continue;

          links[trigger.target] = links[trigger.target] || new Set();
          links[trigger.target].add(node);
        }
      }

      return links;
    },
    ...clipboard.computed
  },
  methods: {
    focus(node) {
      this.$emit('focus', node);
    },
    addTrigger(node) {
      node.triggers.push({
        mode: 'goto', // fork | goto | kill | random | dispatch | set
        event: 'node-end',

        predicateExpression: '', // Used with events that have values
        timePassedDuration: 0, // Used with 'time-passed' event

        target: node.id, // Used with 'goto' and 'fork' modes
        dispatchEvent: '', // Used with 'dispatch' mode
        dispatchExpression: '',
        setVariable: '', // Used with 'set' mode
        setExpression: '',

        crossfade: false, // Used when goto/fork a node with music
        preserveLocation: false,
        crossfadeDuration: 1,
        locationMultiplier: 1,

        anchor: { // Location of connections for visual editor
          origin: { x: 100, y: 60 },
          target: { x: 100, y:  0 }
        }
      });
      this.$emit('change');
    },
    shiftNode(node, dir) {
      let index = this.nodes.indexOf(node);
      this.nodes.splice(index, 1);
      this.nodes.splice(index+dir, 0, node);
      this.$emit('change');
    },
    removeNode(node) {
      this.nodes.splice(this.nodes.indexOf(node), 1);
      this.$emit('change');
    },
    copyNode(node) {
      this.copiedNode = node;
      navigator.clipboard.writeText(JSON.stringify([ node ]));
    },
    moveNode(nodeBefore) {
      this.pasteNode(nodeBefore);
      let index = this.nodes.indexOf(this.copiedNode);
      if (index !== -1) this.nodes.splice(index, 1);
      this.$emit('change');
    },
    pasteNode(nodeBefore) {
      this.$emit('pasteNode', nodeBefore);
      this.$emit('change');
    },
    pasteTrigger(target) {
      if (!this.copiedTrigger) return;
      let copy = JSON.parse(JSON.stringify(this.copiedTrigger));
      target.triggers.push(copy);
      this.$emit('change');
    }
  }
}
