const html = arg => arg.join('');
import OptionToggle from './OptionToggle.js';
import { KEYS } from '../../importers/generic-texture.js';

export default {
  template: html`
    <div class="component-wrapper">
      <div class="control-group">
        <button @click="openMiscChanger" title="Opens an editor for other non-block skins">
          Edit other skins
        </button>
        <div class="skin-load-indicators">
          <span
            v-for="skin of loaded_skins"
            class="skin-load-indicator"
            :class="previewClass(skin)">
            {{ skin.key }}
          </span>
        </div>
        <option-toggle storageKey="winterCompatEnabled">
          Enable winter 2021 event board skin format compatibility patch
        </option-toggle>
      </div>
    </div>
  `,
  components: { OptionToggle },
  data: () => ({
    loaded_skins: Object.values(KEYS).map(({ storagekey }) => {
      return { key: storagekey, exists: null }
    })
  }),
  async mounted() {
    for (let entry of this.loaded_skins) {
      let values = await browser.storage.local.get(entry.key);
      entry.exists = !!values[entry.key];
    }
  },
  methods: {
    previewClass(skin) {
      return skin.exists == null ? 'loading'
        : skin.exists ? 'set'
        : 'unset'
    },
    async openMiscChanger() {
      let url = 'source/panels/generic-texture-replacer/index.html';
      let { name } = await browser.runtime.getBrowserInfo();
      if (name == 'Fennec') {
        browser.tabs.create({
          url: browser.extension.getURL(url),
          active: true
        });
      } else {
        browser.windows.create({
          type: 'detached_panel',
          url: browser.extension.getURL(url),
          width: 659,
          height: 550
        });
      }
    }
  }
}
