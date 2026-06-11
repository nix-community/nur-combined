const html = arg => arg.join('');
import utils from './ve-utils-mixin.js';

export default {
  template: html`
    <div style="display: contents">
      <div
        class="node"
        :class="{ selected }"
        :node-id="node.id"
        :style="{ '--x': node.x + 'px', '--y': node.y + 'px' }"
      >
        {{node.name}}
        <button class="spawn-button" v-if="connected && showAnchors" @click="$emit('spawn')">
          spawn
        </button>
      </div>


      <template v-for="link of links">
        <div
          class="node-anchor origin"
          :node-id="node.id"
          :trigger-index="link.i"
          :style="{ '--x': link.x1 + 'px', '--y': link.y1 + 'px' }"
          v-show="showAnchors"
        ></div>
        <div
          v-if="link.targetType == 'target'"
          class="node-anchor target"
          :node-id="node.id"
          :trigger-index="link.i"
          :style="{ '--x': link.x2 + 'px', '--y': link.y2 + 'px' }"
          v-show="showAnchors"
        ></div>
      </template>
    </div>
  `,
  props: ['nodes', 'node', 'connected', 'show-anchors'],
  mixins: [utils],
  computed: {
    selected() {
      return this.isSelected(this.node);
    },
    links() {
      return this.getLinks(this.node, this.node.triggers);
    }
  }
}
