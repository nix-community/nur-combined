import VisualEditor from './components/visual-editor/visual-editor.js';
import NodeEditor from './components/node-editor.js';
import * as clipboard from './clipboard.js';
import debug from './debug.js';
const html = arg => arg.join(''); // NOOP, for editor integration.
import /* non ES6 */ '../../shared/migrate.js';
import /* non ES6 */ '../../shared/tpse-sanitizer.js';
import Debugger from './components/debugger.js';

const app = new Vue({
  template: html`
    <div class="split-pane" :class="{ 'debugger-active': !!debug.port }">
      <div class="node-editor">
        <div class="pane-header">
          <button @click="save">Save changes</button>
          <span :style="{ opacity: this.saveOpacity }">Saved!</span>
          <span style="float: right;">
            <button @click="undo" :disabled="history.undo.length <= 1">
              Undo (x{{ history.undo.length-1 }})
            </button>
            <button @click="redo" :disabled="history.redo.length == 0">
              Redo (x{{ history.redo.length }})
            </button>
          </span>
        </div>
        <div class="node-list">
          <fieldset>
            <legend>Global configuration <button @click="resetConfig">reset</button></legend>
            <b>Increasing these can lag your game.</b>

            <div>
              Active node limit:
              <input
                type="number"
                v-model.number="config.nodeLimit"
                min="1"
                @change="saveConfig"
              />
            </div>

            <div>
              Reported event rate limit:
              <input
                type="number"
                v-model.number="config.reportedEventRateLimit"
                min="1"
                @change="saveConfig"
              />/s
            </div>

            <div>
              Hard event rate limit:
              <input
                type="number"
                v-model.number="config.hardEventRateLimit"
                min="1"
                @change="saveConfig"
              />/s
            </div>
          </fieldset>
          
          <node-editor
            v-for="node of nodes"
            :key="node.id"
            :nodes="nodes"
            :node="node"
            @change="pushState"
            @pasteNode="pasteNode"
            @focus="focus"
          />
        </div>
        <button @click="addNode()">Add node</button>
        <button @click="pasteNode()" :disabled="!copiedNode">Paste node</button>
        <div class="scroll-past-end"></div>
      </div>
      <visual-editor :nodes="nodes" :debug="debug" @focus="focus" @change="pushState" ref="veditor" />
      <debugger v-show="debug.port" :debug="debug" ref="debugger"></debugger>
    </div>
  `,
  data: {
    history: { undo: [], redo: [] },
    config: {
      nodeLimit: 0,
      reportedEventRateLimit: 0,
      hardEventRateLimit: 0
    },
    nodes: [],
    maxId: 0,
    saveOpacity: 0,
    clipboard: clipboard.clipboard,
    debug: debug
  },
  components: { NodeEditor, VisualEditor, Debugger },
  computed: {
    ...clipboard.computed
  },
  methods: {
    async resetConfig() {
      this.config.nodeLimit = 100;
      this.config.reportedEventRateLimit = 100;
      this.config.hardEventRateLimit = 100;
      await this.saveConfig();
    },
    async saveConfig() {
      await browser.storage.local.set({
        musicGraphNodeLimit: this.config.nodeLimit,
        musicGraphReportedEventRateLimit: this.config.reportedEventRateLimit,
        musicGraphHardEventRateLimit: this.config.hardEventRateLimit
      });
    },
    pushState() {
      this.history.undo.push(JSON.stringify(this.nodes));
      this.history.redo.splice(0);
      let length = this.history.undo.reduce((acc, el) => acc + el.length, 0);
      if (length > 1024*1024 && this.history.undo.length > 10)
        this.history.undo.splice(0, 1);
    },
    undo() {
      let state = this.history.undo.pop();
      this.history.redo.push(JSON.stringify(this.nodes));
      this.nodes = JSON.parse(this.history.undo[this.history.undo.length-1]);
    },
    redo() {
      let state2 = this.history.redo.pop();
      this.history.undo.push(state2);
      this.nodes = JSON.parse(state2);
    },
    addNode() {
      let node = {
        id: ++this.maxId,
        type: 'normal',
        name: 'new node ' + this.maxId,
        audio: null,
        background: null,
        backgroundLayer: 0,
        backgroundArea: 'background',
        audioStart: 0,
        audioEnd: 0,
        triggers: [],
        hidden: false,
        singleInstance: false,
        effects: {
          volume: 1,
          speed: 1
        },
        x: 0,
        y: 0
      };
      this.nodes.push(node);
      this.$nextTick(() => this.$emit('change'));
      return node;
    },
    save() {
      browser.storage.local.set({
        musicGraph: JSON.stringify(this.nodes)
      });
      this.saveOpacity = 1.25;
      let timeout = setInterval(() => {
        this.saveOpacity -= 0.1;
        if (this.saveOpacity <= 0)
          clearTimeout(timeout);
      }, 50);
      this.$emit('save');
    },
    pasteNode(nodeBefore) {
      if (!this.copiedNode) return;
      let index = this.nodes.indexOf(nodeBefore);
      if (index == -1) index = this.nodes.length;
      let copy = JSON.parse(JSON.stringify(this.copiedNode));
      copy.id = ++this.maxId;
      this.nodes.splice(index, 0, copy);
      this.$emit('change');
    },
    focus(node) {
      if (typeof node == 'number')
        node = { id: node };

      let target;

      if (node.id === undefined && node.event) { // is a trigger object
        let trigger = node;
        for (let inode of this.nodes) {
          let index = inode.triggers.indexOf(trigger);
          if (index == -1) continue;
          let nodeEl = document.getElementById('node-' + inode.id);
          target = nodeEl.querySelector(`[trigger-index="${index}"]`);
          // fallback when collapsed with v-show: false (i.e. `display: none`)
          if (!target.offsetParent) target = nodeEl;
        }
      } else { // is a node object
        target = document.getElementById('node-' + node.id);
      }

      if (!target) return;

      target.scrollIntoView({
        behavior: 'auto',
        block: 'center',
        inline: 'center'
      });

      target.classList.add('highlighted');
      setTimeout(() => {
        target.classList.remove('highlighted');
      }, 1000);
    }
  },
  mounted() {
    Object.assign(this.addNode(), {
      id: 0,
      type: 'root',
      name: 'root'
    });
    this.maxId = 0;

    browser.storage.local.get([
      'musicGraph',
      'musicGraphNodeLimit',
      'musicGraphReportedEventRateLimit',
      'musicGraphHardEventRateLimit'
    ]).then((opt) => {
      this.config.nodeLimit = opt.musicGraphNodeLimit ?? 100;
      this.config.reportedEventRateLimit = opt.musicGraphReportedEventRateLimit ?? 250;
      this.config.hardEventRateLimit = opt.musicGraphHardEventRateLimit ?? 10000;
      this.saveConfig();
      if (opt.musicGraph) {
        this.nodes = opt.musicGraph;
        this.maxId = Math.max(...this.nodes.map(node => node.id));
      }
    }).then(() => {
      this.pushState();
    });
    
    window.addEventListener('keydown', event => {
      let tag = event.target.tagName;
      if (['INPUT', 'TEXTAREA'].includes(tag))
        return;

      switch (event.key) {
        case 'z':
          if (!event.ctrlKey || this.history.undo.length <= 1) break;
          this.undo();
          break;

        case 'y':
          if (!event.ctrlKey || this.history.redo.length == 0) break;
          this.redo();
          break;

        case 'Escape':
          this.selected.splice(0);
          break;

        case 'Delete':
          for (let node of this.selected) {
            if (node.type == 'root') continue;
            let index = this.nodes.indexOf(node);
            if (index == -1) continue;
            this.nodes.splice(index, 1);
          }
          this.selected.splice(0);
          this.pushState();
          break;
      }
    });
    
    this.$on('save', () => {
      if (!this.debug.port) return;
      this.debug.port.postMessage({ type: 'reload' });
    });
  }
});
app.$mount('#app');
window.app = app;
