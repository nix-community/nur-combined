import OptionToggle from './OptionToggle.js';
const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <div class="component-wrapper">
      <div class="control-group">
        <button @click="openMusicEditor" title="Opens the music editor window">
          Open music editor
        </button>
        <button @click="openMusicGraphEditor()" title="Opens the music graph editor">
          Open music graph editor
        </button>
      </div>

      <div class="option-group">
        <option-toggle storageKey="musicEnabled">
          <span title="Enables custom music">
            Enable custom music
          </span>
        </option-toggle>
        <option-toggle storageKey="musicGraphEnabled" enabledIfKey="musicEnabled">
          <span title="Enables the music graph">
            Enable music graph
          </span>
        </option-toggle>
        <option-toggle storageKey="disableVanillaMusic" enabledIfKey="musicEnabled">
          <span title="Removes the game's existing soundtrack">
            Remove built in music
          </span>
        </option-toggle>
      </div>

      <option-toggle storageKey="musicEnabled" mode="show">
        <hr />
        <div class="preview-group">
          <div v-if="music.length == 0">
            No custom music
          </div>
          <div class="song" v-else v-for="song of music">
            <span class="song-category">
              {{ song.metadata.genre.slice(0,1) }}
            </span>
            <span class="song-name" :title="JSON.stringify(song, null, 2)">
              {{ song.filename }}
            </span>
          </div>
        </div>
      </option-toggle>
    </div>
  `,
  data: () => ({ cache: { music: null } }),
  components: { OptionToggle },
  computed: {
    music() {
      browser.storage.local.get('music').then(({ music }) => {
        this.cache.music = music;
      });
      if (!this.cache.music) return [];
      return this.cache.music;
    }
  },
  methods: {
    openMusicEditor() {
      browser.tabs.create({
        url: browser.extension.getURL(
          'source/panels/musiceditor/index.html'
        ),
        active: true
      });
    },
    openMusicGraphEditor() {
      browser.tabs.create({
        url: browser.extension.getURL(
          'source/panels/musicgrapheditor/index.html'
        ),
        active: true
      });
    }
  }
}
