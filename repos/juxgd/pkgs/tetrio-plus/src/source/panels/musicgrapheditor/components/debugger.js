const html = arg => arg.join('');

export default {
  template: html`
    <div class="debugger">
      <div><b>Debugger</b></div>
      
      <div>
        <label for="pick_replay">Load event replay</label><br>
        <input id="pick_replay" type="file" accept="application/json" ref="pickReplay" @change="read()"/>
      </div>
      
      <hr>
      
      <div v-if="replay">
        <div>
          Step controls:
          <button @click="replay.time = 0; replay.index = 0;">Restart</button>
          <button @click="step(-1)">Prev</button>
          <button @click="step(1)">Next</button>
        </div>
        
        <div>
          <input type="checkbox" v-model.boolean="nextPrevSend"/>
          <label @click="nextPrevSend = !nextPrevSend">Prev/next sends event</label>
        </div>
        
        <fieldset>
          <legend>Jump to index</legend>
          <label>Jump index</label><br>
          <input v-model.number="jumpToIndex">
          <button @click="replay.index = jumpToIndex">Jump</button>
        </fieldset>
        
        speed: {{ replay.speed }}<br>
        <button v-for="speed of [0.25, 0.5, 0.75, 1.0, 1.25, 1.5, 2.0, 3.0, 5.0, 10.0, 100.0]" @click="replay.speed = speed">{{speed}}x</button>
        
        <br>
        
        <button @click="replay.paused = !replay.paused">{{ replay.paused ? 'Unpause' : 'Pause' }}</button>
        Time: {{ this.replay.time.toFixed(2) }}
        
        <div class="replay-log">
          <div>| Index | &nbsp;Time&nbsp; | Event</div>
          <replay-item v-for="x of [-5, -4, -3, -2, -1, 0, 1, 2, 3, 4, 5]" :item="replay.events[replay.index + x]" :active="x == 0"/>
        </div>
      </div>
      <div v-else>
        No event replay loaded
      </div>
    </div>
  `,
  components: {
    ReplayItem: {
      template: html`
        <div class="replay-item" :class="{ active }" v-if="item">
          {{ item.sequence.toString().padStart(5, '0') }} | {{ item.time.toFixed(2).padStart(6, '0') }} | {{item.event}} {{values}}
        </div>
        <div class="replay-item empty" :class="{ active }" v-else></div>
      `,
      props: ['item', 'active'],
      computed: {
        values() {
          return Object.entries(this.item.value).map(([k,v]) => `${k}=${v}`).join(' ')
        }
      }
    }
  },
  data: () => ({
    replay: null,
    jumpToIndex: 0,
    nextPrevSend: true
  }),
  props: ['debug'],
  mounted() {
    setInterval(() => this.tickPlayback(), 1000/64);
  },
  methods: {
    step(delta) {
      let newIndex = Math.min(Math.max(this.replay.index + delta, 0), this.replay.events.length);
      if (newIndex != this.replay.index) {
        this.replay.index = newIndex;
        let evt = this.replay.events[this.replay.index];
        if (evt) this.replay.time = evt.time;
        if (this.nextPrevSend)
          this.sendCurrentEvent();
      }
    },
    tickPlayback() {
      if (!this.replay)
        return;
      let dt = performance.now() - this.replay.lastTick;
      this.replay.lastTick += dt;
      if (!this.debug.port) {
        this.replay.paused = true;
        return;
      }
      if (this.replay.paused)
        return;
      this.replay.time += dt/1000 * this.replay.speed;
      while (this.replay.index < this.replay.events.length && this.replay.time > this.replay.events[this.replay.index].time) {
        this.sendCurrentEvent();
        this.replay.index += 1;
      }
    },
    sendCurrentEvent() {
      this.debug.port.postMessage({
        type: 'event',
        event: this.replay.events[this.replay.index].event,
        value: this.replay.events[this.replay.index].value
      });
    },
    async read() {
      let [file] = this.$refs.pickReplay.files;
      if (!file) return;
      let result = await new Promise(res => {
        let reader = new FileReader();
        reader.addEventListener('load', () => res(reader.result), false);
        reader.readAsText(file);
      });
      try {
        let replay = JSON.parse(result);
        if (replay.__schema != "tetrio-plus-music-graph-replay")
          throw new Error("file doesn't appear to be a music graph replay (expected $.schema == 'tetrio-plus-music-graph-replay')")
        let events = [];
        let sequence = 0;
        for (let item of replay.events) {
          if (typeof item.real_time != 'number') throw new Error("$.events[].real_time: expected a number");
          if (typeof item.event != 'string') throw new Error("$.events[].event: expected a string");
          if (typeof item.value != 'object') throw new Error("$.events[].value: expected an object");
          for (let [key, value] of Object.entries(item.value))
            if (typeof value != 'number')
              throw new Error("$.events[].value.{}: expected a number");
          events.push({ sequence: sequence++, time: (item.real_time - replay.events[0].real_time)/1000, event: item.event, value: item.value });
        }
        this.replay = {
          time: 0,
          paused: true,
          lastTick: performance.now(),
          speed: 1,
          index: 0,
          events: Object.freeze(events)
        };
      } catch(ex) {
        alert("Failed to load replay, see console for details");
        console.log(ex);
      }
      console.log(result);
    }
  }
}