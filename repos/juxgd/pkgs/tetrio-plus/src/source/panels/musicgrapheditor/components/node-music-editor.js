const html = arg => arg.join(''); // NOOP, for editor integration.

const music = [];
const backgrounds = [];
browser.storage.local.get([ 'music', 'backgrounds' ]).then(res => {
  if (res.backgrounds) backgrounds.push(...res.backgrounds);
  if (res.music) music.push(...res.music);
});

export default {
  template: html`
    <div class="section" v-if="node.type != 'root'">
      <label for="audio">Select audio:</label>
      <select name="audio" class="node-audio-selector" v-model="node.audio" @change="$emit('change')">
        <option :value="null">None</option>
        <option v-for="song of music" :value="song.id">
          {{ song.filename }} (ID: {{ song.id }})
        </option>
      </select>
      <div v-if="music.length == 0">
        (Add music in the main TETR.IO PLUS menu)
      </div>

      <template v-if="node.audio">
        <div class="form-control" v-if="">
          <label for="volume">Volume</label>
          <input
            name="volume"
            type="range"
            v-model.number="node.effects.volume"
            @change="$emit('change')"
            step="0.01"
            min="0"
            max="1"
          />
          <span class="form-control-value-display">
            {{(node.effects.volume*100).toFixed(0)}}%
          </span>
        </div>
        <div class="form-control">
          <label for="speed">Speed</label>
          <input
            name="speed"
            type="number"
            v-model.number="node.effects.speed"
            @change="$emit('change')"
            step="0.01"
            min="0"
            max="10"
          />x
          <span class="form-control-value-display">
            (affects pitch)
          </span>
        </div>
        <div class="form-control">
          <label for="start-position">Start position</label>
          <input
            name="start-position"
            type="number"
            v-model.number="node.audioStart"
            @change="$emit('change')"
            min="0"
          />s
        </div>
        <div class="form-control">
          <label for="end-position">End position</label>
          <input
            name="end-position"
            type="number"
            v-model.number="node.audioEnd"
            @change="$emit('change')"
            min="0"
          />s
          <span class="form-control-value-display">
            (0 = end of song)
          </span>
        </div>
      </template>

      <label for="background">Select background:</label>
      <select
        name="background"
        class="node-audio-selector"
        v-model="node.background"
        @change="$emit('change')"
      >
        <option :value="null">None</option>
        <option :value="bg.id" v-for="bg of backgrounds">
          {{ bg.filename }} (ID: {{ bg.id }})
        </option>
      </select>
      <div v-if="backgrounds.length == 0">
        (Add backgrounds in the main TETR.IO PLUS menu)
      </div>

      <div v-if="node.background">
        <label for="background-layer">Background layer:</label>
        <input
          name="background-layer"
          type="number"
          v-model.number="node.backgroundLayer"
          @change="$emit('change')"
        />
        <br>
        <label for="backgroundArea">Background area:</label>
        <select name="backgroundArea" v-model="node.backgroundArea" @change="$emit('change')">
          <option :value="'background'">Background</option>
          <option :value="'foreground'">Foreground</option>
        </select>
      </div>

      <div>
        <input
          name="single-instance"
          v-model="node.singleInstance"
          type="checkbox"
          @change="$emit('change')"
        />
        <label for="single-instance">Force single instance (destroys duplicates)</label>
      </div>
    </div>
  `,
  props: ['node'],
  data: () => ({ music, backgrounds })
}
