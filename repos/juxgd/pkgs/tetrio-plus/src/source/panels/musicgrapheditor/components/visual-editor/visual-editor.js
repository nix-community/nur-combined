import {clipboard} from '../../clipboard.js';
const html = arg => arg.join(''); // NOOP, for editor integration.

import veSvgContainer from './ve-svg-container.js';
import veSvgNodeLinks from './ve-svg-node-links.js';
import veLiveNode from './ve-live-node.js';
import veNode from './ve-node.js';
import utils from './ve-utils-mixin.js';

export default {
  template: html`
    <div ref="editor" class="visual-editor" :class="editorClass" :style="editorStyle" tabindex="0" @wheel="wheel">
      <div class="events-per-second" v-if="debug.port">
        Events per second: {{ debug.eventsPerSecond }}
        <div v-if="debug.eventsPerSecondWarning">
          ⚠️ Above reporting threshold, some events may not display.
        </div>
      </div>
      <button class="reset-zoom" v-if="camera.scale != 1" @click="camera.scale = 1">Reset zoom</button>
      <div :style="scaleContainerStyle">
        <div :style="translateContainerStyle">
          <ve-node
            v-for="node of nodes"
            :key="node.id"
            :nodes="nodes"
            :node="node"
            :connected="!!debug.port"
            :show-anchors="camera.scale > 0.5"
            @spawn="spawn(node)"
          />
          <div style="display: contents">
            <ve-live-node
              v-for="instance of debug.liveInstances"
              v-if="isFinite(instance.sourceId)"
              :key="instance.instanceId"
              :camera="camera"
              :nodes="nodes"
              :node="getNodeById(instance.sourceId)"
              :instance="instance"
              :index="liveInstancesByNode[instance.sourceId].indexOf(instance)"
              v-show="camera.scale > 0.5"
              @kill="kill(instance.instanceId)"
            />
          </div>
        </div>
        <ve-svg-container :camera="camera" :select-rect="selectRect" v-show="camera.scale > 0.25">
          <ve-svg-node-links
            v-for="node of nodes"
            :key="node.id"
            :nodes="nodes"
            :node="node"
            :events="debug.recentTriggerFires[node.id] || []"
            :draw-thick="camera.scale <= 0.5"
            :show-labels="camera.scale > 0.5"
          />
        </ve-svg-container>
      </div>
    </div>
  `,
  props: ['nodes', 'debug'],
  components: { veSvgContainer, veSvgNodeLinks, veLiveNode, veNode },
  mixins: [utils],
  data: () => ({
    camera: { x: 0, y: 0, scale: 1 },
    selectRect: null,
  }),
  computed: {
    liveInstancesByNode() {
      let map = {};
      for (let node of this.debug.liveInstances) {
        if (!map[node.sourceId]) map[node.sourceId] = [];
        map[node.sourceId].push(node);
      }
      return map;
    },
    editorClass() {
      return {
        'tiny': this.camera.scale <= 0.5,
        'very-tiny': this.camera.scale <= 0.1
      };
    },
    editorStyle() {
      return {
        '--bg-x': this.camera.x + 'px',
        '--bg-y': this.camera.y + 'px',
        '--bg-scale': this.camera.scale,
        '--bg-color': this.camera.scale >= 0.5 ? 'gray' : 'transparent'
      }
    },
    scaleContainerStyle() {
      return {
        transform: `scale(${this.camera.scale})`,
        width: (100 / this.camera.scale) + '%',
        height: (100 / this.camera.scale) + '%',
        'transform-origin': '0 0'
      }
    },
    translateContainerStyle() {
      return {
        'will-change': 'transform',
        transform: `translateX(${this.camera.x/this.camera.scale}px) translateY(${this.camera.y/this.camera.scale}px)`
      }
    },
    svgTransform() {
      return `translate(${this.camera.x}, ${this.camera.y})`
    }
  },
  methods: {
    wheel(evt) {
      let {top, left} = this.$refs.editor.getBoundingClientRect()
      this.camera.x -= evt.clientX - left;
      this.camera.y -= evt.clientY - top;
      this.camera.x /= this.camera.scale;
      this.camera.y /= this.camera.scale;
      this.camera.scale -= evt.deltaY / 1000;
      if (this.camera.scale < 0.1) this.camera.scale = 0.1;
      this.camera.x *= this.camera.scale;
      this.camera.y *= this.camera.scale;
      this.camera.x += evt.clientX - left;
      this.camera.y += evt.clientY - top;
    },
    editorRect() {
      return this.$refs.editor.getBoundingClientRect();
    },
    round(val, step) {
      return Math.round(val / step) * step;
    },
    async copy(event) {
      let active = document.activeElement;
      if (active != this.$refs.editor && active != document.body) return;

      let data = JSON.stringify(clipboard.selected, null, 2);
      event.clipboardData.setData('text/plain', data);
      event.preventDefault();
    },
    async paste(event) {
      let active = document.activeElement;
      if (active != this.$refs.editor && active != document.body) return;

      let musicGraph = null;
      let result = await sanitizeAndLoadTPSE(
        {
          version: '0.25.3',
          musicGraph: JSON.parse(event.clipboardData.getData('text'))
        },
        {
          async set(pairs) {
            if (pairs.musicGraph) {
              musicGraph = pairs.musicGraph;
            }
          }
        },
        { skipFileDependencies: true }
      );
      if (result.includes('ERROR')) {
        alert(`Paste failed:\n${result}`);
        return;
      }
      console.log("pasted", result, musicGraph);
      if (!musicGraph) return;

      let ax = musicGraph.reduce((acc, node) => acc + node.x, 0) / musicGraph.length;
      let ay = musicGraph.reduce((acc, node) => acc + node.y, 0) / musicGraph.length;
      let { width, height } = this.$refs.editor.getBoundingClientRect();
      clipboard.selected.splice(0);

      let idMap = new Map();
      for (let node of musicGraph) {
        if (node.type == 'root') continue;
        let newId = ++this.$parent.maxId;
        idMap.set(node.id, newId);
        node.id = newId;
        node.x = Math.floor((node.x - ax - this.camera.x + width /2) / 20) * 20;
        node.y = Math.floor((node.y - ay - this.camera.y + height/2) / 20) * 20;
        this.nodes.push(node);
        clipboard.selected.push(node);
      }

      for (let node of musicGraph)
        for (let trigger of node.triggers)
          if (idMap.has(trigger.target))
            trigger.target = idMap.get(trigger.target);

      if (musicGraph.length > 0)
        this.$emit('change');
    },
    spawn(node) {
      this.debug.port.postMessage({
        type: 'spawn',
        sourceId: node.id
      });
    },
    kill(instanceId) {
      this.debug.port.postMessage({
        type: 'kill',
        instanceId
      });
    }
  },
  mounted() {
    this.copy = this.copy.bind(this);
    this.paste = this.paste.bind(this);
    window.addEventListener('copy', this.copy);
    window.addEventListener('paste', this.paste);
    window.ve = this;

    interact('.visual-editor svg text')
      .on('tap', event => {
        let trigger = this.getTriggerFromElem(event.target);
        this.$emit('focus', trigger);
      });

    interact('.visual-editor')
      .draggable({})
      .on('dragmove', event => {
        if (event.shiftKey) {
          if (!this.selectRect) {
            this.selectRect = {
              x1: event.clientX0,
              y1: event.clientY0,
              x2: event.clientX0,
              y2: event.clientY0
            };
          }
          this.selectRect.x2 += event.delta.x;
          this.selectRect.y2 += event.delta.y;
        } else {
          this.camera.x += event.dx;
          this.camera.y += event.dy;
        }
      })
      .on('dragend', event => {
        if (event.shiftKey) {
          let trect = {
            top: Math.min(this.selectRect.y1, this.selectRect.y2),
            bottom: Math.max(this.selectRect.y1, this.selectRect.y2),
            left: Math.min(this.selectRect.x1, this.selectRect.x2),
            right: Math.max(this.selectRect.x1, this.selectRect.x2),
          };

          if (!event.ctrlKey)
            clipboard.selected.splice(0);

          for (let node of this.nodes) {
            let rect = document.querySelector(`[node-id="${node.id}"]`).getBoundingClientRect();
            if (rect.top > trect.bottom) continue;
            if (rect.left > trect.right) continue;
            if (rect.bottom < trect.top) continue;
            if (rect.right < trect.left) continue;
            clipboard.selected.push(node);
          }
          this.selectRect = null;
        }
      })

    interact('.visual-editor .node')
      .draggable({
        modifiers: [
          interact.modifiers.snap({
            targets: [
              interact.createSnapGrid({ x: 20 / this.camera.scale, y: 20 / this.camera.scale })
            ],
            relativePoints: [{ x: 0, y: 0 }],
            offset: 'self'
          })
        ]
      })
      .on('dragmove', event => {
        let node = this.getNodeFromElem(event.target);
        let set = clipboard.selected.indexOf(node) !== -1 ? clipboard.selected : [node];
        for (let node of set) {
          node.x += event.dx / this.camera.scale;
          node.y += event.dy / this.camera.scale;
        }
      })
      .on('dragend', event => {
        let node = this.getNodeFromElem(event.target);
        let set = clipboard.selected.indexOf(node) !== -1 ? clipboard.selected : [node];
        for (let node of set) {
          node.x = this.round(node.x, 20);
          node.y = this.round(node.y, 20);
        }
        this.$emit('change');
      })
      .on('tap', event => {
        if (event.target.tagName == 'BUTTON') return;
        let node = this.getNodeFromElem(event.target);
        if (!event.ctrlKey && !event.shiftKey)
          clipboard.selected.splice(0);

        let index = clipboard.selected.indexOf(node);
        if (index == -1)
          clipboard.selected.push(node)
        else if (event.ctrlKey)
          clipboard.selected.splice(index, 1);

        this.$emit('focus', node);
      });

    const dx = Symbol("dx");
    const dy = Symbol("dy");
    interact('.visual-editor .node-anchor')
      .draggable({})
      .on('dragstart', event => {
        let trigger = this.getTriggerFromElem(event.target);
        let coord = trigger.anchor[this.getHandleTypeFromElem(event.target)];
        coord[dx] = coord.x;
        coord[dy] = coord.y;
      })
      .on('dragmove', event => {
        let trigger = this.getTriggerFromElem(event.target);
        let coord = trigger.anchor[this.getHandleTypeFromElem(event.target)];
        coord[dx] += event.dx / this.camera.scale;
        coord[dy] += event.dy / this.camera.scale;
        let rx = Math.abs(0.5 - coord.x/200);
        let ry = Math.abs(0.5 - coord.y/60);
        coord.x = rx > ry ? (coord[dx] < 100 ? 0 : 200) : Math.min(Math.max(coord[dx], 0), 200);
        coord.y = ry > rx ? (coord[dy] < 30 ? 0 : 60) : Math.min(Math.max(coord[dy], 0), 60);
      })
      .on('dragend', event => {
        let trigger = this.getTriggerFromElem(event.target);
        let coord = trigger.anchor[this.getHandleTypeFromElem(event.target)];
        delete coord[dx];
        delete coord[dy];
        this.$emit('change');
      })
  }
}
