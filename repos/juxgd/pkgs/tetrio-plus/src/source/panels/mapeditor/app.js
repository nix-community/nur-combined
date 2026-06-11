const html = arg => arg.join(''); // NOOP, for editor integration.

const VALID_BAG_CHARS = ['i', 'o', 'l', 'j', 'z', 's', 't', 'oo'];

const app = new Vue({
  template: html`
    <div class="app">
      <div class="tools">
        <h3>Tools</h3>
        <div class="tool-container" v-for="itool of tools">
          <div
            @mousemove="clicking && (tool = itool)"
            @click="tool = itool"
            :class="{
              mino: true,
              tool: true,
              ['mino-' + itool]: true,
              ['active-tool']: tool == itool
            }"
          ></div>
          {{ itool }}
        </div>

        <h3>Extra pieces</h3>
        <div class="tool-container" v-for="[piece, color] of extra_pieces">
          <div class="mino tool disabled" :style="{ backgroundColor: color }"></div>

          {{ piece }}
          <button @click="bag.push(piece)" style="margin-left: 4px">+bag</button>
          <button @click="hold = piece" style="margin-left: 4px">+hold</button>
        </div>
      </div>
      <div class="editor">
        <div v-for="(row, i) of map" class="row" :class="{ upper: i < 20 }">
          <div
            v-for="el of row"
            class="mino"
            :class="'mino-' + el.mino"
            @mousemove="edit(el)"
            @click="el.mino = tool"
          ></div>
        </div>
      </div>
      <div class="map-output">
        Paste this into the 'Custom Map String' field after editing and make
        sure to check the 'Use Custom Map' checkbox. You can type into any of
        these fields and the others will automatically update.<br>
        <textarea
          class="map-string"
          ref="mapstring"
          @input="loadMapString($event.target.value)"
        />
        <br />

        <div>
          Bag:
          <input type="text" v-model="bagString" @input="deferRecalcMapString()"/>
          <button @click="addToolToBag()" :disabled="tool.length != 1">
            Add selected
          </button>
          <div style="color: orange" v-if="bagError">{{ bagError }}</div>
        </div>

        <div>
          Hold:
          <input type="text" v-model="hold" @input="deferRecalcMapString()" />
          <button @click="setHoldToTool()" :disabled="tool.length != 1">
            Set selected
          </button>
          <div style="color: orange" v-if="holdError">{{ holdError }}</div>
        </div>

        <div>
          Width:
          <input type="number" v-model.number="width" min="1" />
        </div>

        <div>
          Height:
          <input type="number" v-model.number="height" min="1" />
        </div>
      </div>
    </div>
  `,
  data: {
    width: 10,
    height: 40,
    map: [],
    tools: ['i', 'o', 'l', 'j', 'z', 's', 't', 'empty', 'garbage', 'darkgarbage'],
    extra_pieces: [['oo', 'yellow']],
    bag: [],
    hold: null,
    tool: 'empty',
    removing: false,
    clicking: false,
    mapString: "",
    modified: false
  },
  mounted() {
    document.addEventListener('mousedown', () => this.startEditing());
    document.addEventListener('mouseup', () => this.endEditing());
    this.regenerateMap();
    this.recalculateMapString();
    let match = /map=([^&]+)/.exec(window.location.search);
    if (match) {
      this.loadMapString(decodeURIComponent(match[1]));
      this.recalculateMapString();
    }
  },
  computed: {
    bagString: {
      get() {
        return this.bag.join(',');
      },
      set(val) {
        this.bag = val.split(',');
      }
    },
    bagError() {
      if (this.bag.includes('?'))
        return `Bag contains disallowed seperator character '?'`

      if (this.bag[this.bag.length-1] == '')
        return `Bag contains a trailing comma`;

      let charErrors = this.bag.filter(entry => VALID_BAG_CHARS.indexOf(entry) == -1);
      if (charErrors.length > 0)
        return `Bag contains possibly invalid values: "${charErrors[0]}"`;
    },
    holdError() {
      let error = this.hold && this.hold.length > 0 && VALID_BAG_CHARS.indexOf(this.hold) == -1;
      if (error) return `Hold contains possibly invalid values`;
    }
  },
  watch: {
    mapString(val) {
      this.$refs.mapstring.value = val;
    },
    bag() {
      this.deferRecalcMapString();
    },
    hold() {
      this.deferRecalcMapString();
    },
    width() {
      this.regenerateMap()
    },
    height() {
      this.regenerateMap()
    }
  },
  methods: {
    regenerateMap() {
      let oldHeight = this.map.length;
      this.map = new Array(this.height).fill(0).map((el, y) => {
        return new Array(this.width).fill(0).map((el, x) => {
          let ny = y + oldHeight - this.height;
          if (this.map[ny]?.[x]) return this.map[ny][x];
          return { mino: 'empty' }
        });
      });
      this.deferRecalcMapString();
    },
    startEditing() {
      this.clicking = true;
      this.modified = false;
    },
    endEditing() {
      this.clicking = false;
      if (this.modified) {
        this.recalculateMapString();
        this.modified = false;
      }
    },
    edit(elem) {
      if (!this.clicking) return;
      elem.mino = this.tool;
      this.modified = true;
    },
    addToolToBag() {
      this.bag.push(this.tool);
      this.deferRecalcMapString();
    },
    setHoldToTool() {
      this.hold = this.tool;
      this.deferRecalcMapString()
    },
    deferRecalcMapString() {
      setTimeout(() => this.recalculateMapString());
    },
    recalculateMapString() {
      this.mapString = this.map.flatMap(row => {
        return row.map(el => {
          if (el.mino == 'empty') return '_';
          if (el.mino == 'garbage') return '#';
          if (el.mino == 'darkgarbage') return '@';
          return el.mino;
        });
      }).join('');
      let bagged = this.bag.join(',').replace(/\?/g, '');
      this.mapString += `?${bagged}?${this.hold || ""}`;
    },
    loadMapString(mapString) {
      let x = 0, y = 0;

      let [map, bag, hold] = mapString.split('?');

      for (let char of map) {
        if (char == '_') this.map[y][x].mino = 'empty';
        else if (char == '#') this.map[y][x].mino = 'garbage';
        else if (char == '@') this.map[y][x].mino = 'darkgarbage';
        else if (char == 'i') this.map[y][x].mino = 'i';
        else if (char == 'l') this.map[y][x].mino = 'l';
        else if (char == 'j') this.map[y][x].mino = 'j';
        else if (char == 's') this.map[y][x].mino = 's';
        else if (char == 'z') this.map[y][x].mino = 'z';
        else if (char == 'o') this.map[y][x].mino = 'o';
        else if (char == 't') this.map[y][x].mino = 't';
        else continue;
        x++;
        if (x >= 10) {
          x = 0;
          y++;
        }
        if (y >= 40)
          break;
      }

      this.bag = (bag || "").split(',').filter(el => el.length > 0);
      this.hold = (hold || "");
    }
  }
});

app.$mount('#app');
