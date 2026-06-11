const html = arg => arg.join('');
export default {
  template: html`
    <svg style="width: 100%; height: 100%;">
      <defs>
        <marker id="arrow" viewBox="0 0 10 10" refX="5" refY="5"
            markerWidth="12" markerHeight="12"
            orient="auto-start-reverse">
          <path d="M 0 0 L 10 5 L 0 10 z" />
        </marker>
        <marker id="arrow-outline" viewBox="0 0 10 10" refX="5" refY="5"
            markerWidth="12" markerHeight="12"
            orient="auto-start-reverse">
          <path d="M 0 0 L 10 5 L 0 10 z" stroke="black" fill="none"/>
        </marker>
        <marker id="dot" viewBox="0 0 10 10" refX="5" refY="5"
            markerWidth="12" markerHeight="12">
          <circle cx="5" cy="5" r="5" fill="black" />
        </marker>
        <marker id="x" viewBox="0 0 10 10" refX="5" refY="5"
            markerWidth="12" markerHeight="12">
          <path d="
            M 5 5 L 0 0
            M 5 5 L 10 0
            M 5 5 L 0 10
            M 5 5 L 10 10
          " stroke="red" stroke-width="2px" />
        </marker>
        <marker id="?" viewBox="0 0 10 12" refX="5" refY="5"
            markerWidth="24" markerHeight="24">
          <text
            stroke="black"
            dominant-baseline="hanging"
            font-family="monospace"
            font-size="8px"
          >🎲</text>
        </marker>
        <marker id="global" viewBox="0 0 10 12" refX="5" refY="5"
            markerWidth="24" markerHeight="24">
          <text
            stroke="black"
            dominant-baseline="hanging"
            font-family="monospace"
            font-size="8px"
          >🌐</text>
        </marker>
        <marker id="=" viewBox="0 0 5 3" refX="2.6" refY="1.6"
            markerWidth="24" markerHeight="24">
          <path d="M 0 0 L 5 0 L 5 3 L 0 3 L 0 0" fill="black" />
          <path d="M 1 1 L 4 1 M 1 2 L 4 2" stroke="lime" stroke-width="0.5px" />
        </marker>
      </defs>

      <g :transform="svgTransform">
        <slot></slot>
      </g>

      <rect
        v-if="selectRect"
        :x="Math.min(selectRect.x1, selectRect.x2) - this.editorRect().left"
        :y="Math.min(selectRect.y1, selectRect.y2) - this.editorRect().top"
        :width="Math.abs(selectRect.x2 - selectRect.x1)"
        :height="Math.abs(selectRect.y2 - selectRect.y1)"
        fill="none"
        stroke="red"
        stroke-width="2"
      />
    </svg>
  `,
  props: ['camera', 'selectRect'],
  methods: {
    editorRect() {
      return document.querySelector('.visual-editor').getBoundingClientRect();
    }
  },
  computed: {
    svgTransform() {
      return `translate(${this.camera.x / this.camera.scale}, ${this.camera.y / this.camera.scale})`
    }
  }
}
