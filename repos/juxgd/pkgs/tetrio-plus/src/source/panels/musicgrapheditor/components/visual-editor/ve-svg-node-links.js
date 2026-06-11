const html = arg => arg.join('');
import utils from './ve-utils-mixin.js';

export default {
  template: html`
    <g>
      <template v-for="link of links">
        <line
          :x1="link.x1" :y1="link.y1" :x2="link.x2" :y2="link.y2"
          stroke="black"
          :marker-start="!drawThick && link.startCap ? \`url(#\${link.startCap})\` : null"
          :marker-end="!drawThick && link.endCap ? \`url(#\${link.endCap})\` : null"
          :stroke-dasharray="link.trigger.mode == 'fork' ? (drawThick ? '32 16' : '8 4') : null"
          :stroke-width="drawThick ? 10 : 1"
        />
        <line
          :x1="link.x1" :y1="link.y1" :x2="link.x2" :y2="link.y2"
          :opacity="age(link.i).age"
          :stroke="age(link.i).success ? '#FFA500' : '#FF0000'"
          :stroke-width="drawThick ? 10 : 3"
        />
        <text
          :x="link.textX"
          :y="link.textY"
          :fill="color(link.i)"
          :stroke="color(link.i)"
          :stroke-width="color(link.i) > 0 ? 1 : 0"
          :node-id="node.id"
          :trigger-index="link.i"
          :text-anchor="link.textAnchor"
          :dominant-baseline="link.textBaseline"
          v-show="showLabels"
        >​{{ link.label }}</text>
      </template>
    </g>
  `,
  props: ['nodes', 'node', 'events', 'draw-thick', 'show-labels'],
  mixins: [utils],
  methods: {
    age(index) {
      let minAge = 1;
      let success = false;
      for (let evt of this.events) {
        if (evt.trigger != index) continue;
        let newAge = evt.age / evt.maxAge;
        if (newAge < minAge) {
          minAge = newAge;
          success = evt.success;
        }
        minAge = Math.min(minAge, evt.age / evt.maxAge);
      }
      let linear = 1 - Math.max(Math.min(minAge, 1), 0);
      return { age: 1 - Math.pow(1 - linear, 3), success: success };
    },
    color(index) {
      let { age, success } = this.age(index);
      return `rgb(${age * 0xFF}, ${success ? age * 0xA5 : 0}, 0)`;
    }
  },
  computed: {
    links() {
      return this.getLinks(this.node, this.node.triggers);
    }
  }
}
