const html = arg => arg.join('');
export default {
  template: html`
    <div
      class="live-node"
      :class="{ frozen: freeze, 'no-transition': nudged }"
      :style="style"
      @mouseover="freeze = true"
      @mouseleave="freeze = false"
    >
      <div class="live-node-tooltip">
        <div class="tooltip-inner">
          <pre>{{ variables }}</pre>
          <button @click="$emit('kill')">kill</button>
        </div>
      </div>
    </div>
  `,
  props: ['camera', 'nodes', 'node', 'index', 'instance'],
  data: () => ({
    freeze: false,
    lastX: 0,
    lastY: 0,
    nudged: false
  }),
  watch: {
    camera: {
      deep: true,
      handler() {
        this.nudge();
      }
    }
  },
  mounted() {
    this.nudge();
  },
  methods: {
    nudge() { // Prevents animation for 20ms when called, to allow 'nudging' the location
      this.nudged++;
      setTimeout(() => this.nudged--, 20);
    }
  },
  computed: {
    variables() {
      let string = "";
      string += `Node: ${this.node?.name || '?'}\n`;
      string += Object.entries(this.instance.variables)
        .map(([key, value]) => `${key}: ${value}`)
        .join('\n');
      return string;
    },
    style() {
      let size = 16;
      let padding = 2;
      if (!this.freeze) {
        let width = (size + padding * 2);
        this.lastX = (this.node?.x || 0) + this.index * width;
        this.lastY = (this.node?.y || 0);
      }
      return {
        '--size': size + 'px',
        '--padding': padding + 'px',
        '--x': this.lastX + 'px',
        '--y': this.lastY + 'px'
      };
    }
  }

}
