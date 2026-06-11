const html = arg => arg.join(''); // NOOP, for editor integration.
const ctx = new AudioContext();

export default {
  template: html`
    <div class="audioeditor" v-if="!song">
      Pick a song!
    </div>
    <div class="audioeditor" v-else>
      <button class="finish" @click="$emit('done')">×</button>
      <audio ref="player" :src="editingSrc" controls></audio>
      <div class="timer" style="font-family: monospace;">
        Current time: {{ msTime }}ms
        <template v-if="playingBuffer">[approximate]</template>
      </div>
      <div class="control-group">
        <button
          @click="setLoopStart()"
          title="Sets the loop start point to the current position of the player">
          Set loop start
        </button>
        <button
          @click="setLoopEnd()"
          :disabled="!canSetEnd"
          title="Sets the loop end point to the current position of the player">
          Set loop end
        </button>
      </div>
      <div class="control-group" v-if="song.metadata.loop">
        <button @click="restartLooped()">Listen looped from this point</button>
        <button @click="stopLooped()" :disabled="!playingBuffer">Stop</button>
      </div>
      <div class="option-pairs-group">
        <div class="option-pair">
          <label @click="song.metadata.loop = !song.metadata.loop">
            Loop enabled
          </label>
          <input type="checkbox" v-model.boolean="song.metadata.loop"/>
        </div>
        <div class="option-pair">
          <label>Loop start (ms)</label>
          <input type="number" v-model.number="song.metadata.loopStart"></input>
        </div>
        <div class="option-pair">
          <label>Loop length (ms)</label>
          <input type="number" v-model.number="song.metadata.loopLength"></input>
        </div>
        <div class="option-pair">
          <label>Loop end (ms)</label>
          <input type="number" v-model.number="loopEnd"></input>
        </div>
        <div class="option-pair" title="The name of the song">
          <label>Name</label>
          <input type="text" v-model="song.metadata.name"></input>
        </div>
        <div class="option-pair" title="The japanese name of the song">
          <label>Name (jp)</label>
          <input type="text" v-model="song.metadata.jpname"></input>
        </div>
        <div class="option-pair" title="The name of the song artist">
          <label>Artist</label>
          <input type="text" v-model="song.metadata.artist"></input>
        </div>
        <div class="option-pair" title="The japanese name of the song artist">
          <label>Artist (jp)</label>
          <input type="text" v-model="song.metadata.jpartist"></input>
        </div>
        <div class="option-pair" title="Normalization dB">
          <label>Normalization dB</label>
          <input type="text" v-model.number="song.metadata.normalizeDb"></input>
        </div>
        <div class="option-pair" title="The genre determines where the song will play">
          <label>Song pool</label>
          <select v-model="song.metadata.genre">
            <option value="CALM">Calm</option>
            <option value="BATTLE">Battle</option>
            <option value="INTERFACE" disabled>Interface (Doesn't do anything)</option>
            <option value="OVERRIDE">Override</option>
            <option value="DISABLED">Disabled/Music graph only</option>
          </select>
        </div>
        <div class="option-pair" v-if="song.metadata.genre == 'OVERRIDE'">
          <label>Override</label>
          <select v-model="song.override">
            <option value="null">Nothing</option>
            <option :value="key" v-for="[key, song] of Object.entries(builtin)">
              {{ song.name }}
            </option>
          </select>
        </div>
        <div class="option-pair" title="whether the song is shown in the music room">
          <label>Hidden</label>
          <input type="checkbox" v-model.boolean="song.metadata.hidden"></input>
        </div>
      </div>
    </div>
  `,
  props: ['song', 'builtin'],
  data: () => ({
    cachedSrc: null,
    updateInterval: null,
    currentTime: 0,
    playingBuffer: null
  }),
  mounted() {
    this.updateInterval = setInterval(() => {
      if (this.playingBuffer) {
        this.currentTime += 16/1000;
        if (this.currentTime > this.loopEnd/1000)
          this.currentTime -= this.song.metadata.loopLength/1000;
        return;
      }
      if (!this.$refs.player) return;
      this.currentTime = this.$refs.player.currentTime;
    }, 16);
  },
  beforeDestroy() {
    clearInterval(this.updateInterval);
  },
  computed: {
    loopEnd: {
      get() {
        return (
          this.song.metadata.loopStart +
          this.song.metadata.loopLength
        );
      },
      set(end) {
        this.song.metadata.loopLength = end - this.song.metadata.loopStart;
      }
    },
    editingSrc() {
      let key = 'song-' + this.song.id;
      browser.storage.local.get(key).then(result => {
        this.cachedSrc = result[key];
      });
      return this.cachedSrc;
    },
    async decodedAudioAPIBuffer() {
      let buffer = await (await fetch(this.editingSrc)).arrayBuffer();
      return await ctx.decodeAudioData(buffer);
    },
    msTime() {
      return Math.floor(this.currentTime * 1000);
    },
    canSetEnd() {
      return this.msTime > this.song.metadata.loopStart;
    }
  },
  methods: {
    async restartLooped() {
      this.stopLooped();
      this.$refs.player.pause();

      let source = ctx.createBufferSource();
      source.buffer = await this.decodedAudioAPIBuffer;
      source.connect(ctx.destination);
      this.playingBuffer = source;

      source.loopStart = this.song.metadata.loopStart/1000;
      source.loopEnd = this.loopEnd/1000;
      source.loop = true;
      source.start(0, this.currentTime);
    },
    stopLooped() {
      if (this.playingBuffer) {
        this.playingBuffer.stop();
        this.playingBuffer = null;
      }
    },
    setLoopStart() {
      this.song.metadata.loop = true;
      this.song.metadata.loopStart = this.msTime;
    },
    setLoopEnd() {
      this.song.metadata.loop = true;
      this.song.metadata.loopLength = this.msTime - this.song.metadata.loopStart;
    },
    stopLooping() {
      this.song.metadata.loop = false;
      this.song.metadata.loopStart = 0;
      this.song.metadata.loopLength = 0;
    }
  }
}
