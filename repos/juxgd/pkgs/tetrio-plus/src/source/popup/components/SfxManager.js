import OptionToggle from './OptionToggle.js'
const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <div class="component-wrapper">
      <div class="control-group">
        <button @click="openSfxEditor" title="Opens the sfx editor tab">
          Open sfx editor
        </button>
      </div>

      <div class="option-group" title="Enables custom sound effects">
        <option-toggle storageKey="sfxEnabled">
          Enable custom sfx
        </option-toggle>
      </div>

      <option-toggle storageKey="sfxEnabled" mode="show">
        <hr />
        <div class="preview-group">
          <div v-if="!sfxAtlasSrc">
            Custom sfx not set up
          </div>
          <audio
            v-else
            title="All the game's sound effects are loaded from this audio file."
            :src="sfxAtlasSrc"
            controls></audio>
        </div>
      </option-toggle>
    </div>
  `,
  data: () => ({ cachedSfxAtlasSrc: null }),
  components: { OptionToggle },
  computed: {
    sfxAtlasSrc() {
      browser.storage.local.get('customSounds').then(({ customSounds }) => {
        if (this.cachedSfxAtlasSrc != customSounds)
          this.cachedSfxAtlasSrc = customSounds;
      });
      return this.cachedSfxAtlasSrc;
    },
  },
  methods: {
    openSfxEditor() {
      browser.tabs.create({
        url: browser.extension.getURL('source/panels/sfxcomposer/index.html'),
        active: true
      });
    },
  }
}
