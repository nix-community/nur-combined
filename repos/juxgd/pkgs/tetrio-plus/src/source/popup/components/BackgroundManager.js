import OptionToggle from './OptionToggle.js';
import BackgroundEmbed from './BackgroundEmbed.js';
const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <div class="component-wrapper">
      <div class="control-group">
        <button @click="openBgUploader" title="Opens the BG uploader window">
          Add local custom backgrounds
        </button>
      </div>
      <div class="option-group">
        <option-toggle storageKey="bgEnabled">
          <span title="Enables serving custom backgrounds from the extension">
            Enable local custom backgrounds
          </span>
          <option-toggle inline storageKey="bgEnabled" mode="show">
            <span
              class="warning-icon"
              :title="(
                'TETR.IO already supports custom backgrounds. This feature serves them ' +
                'from the extension instead of requiring an external file host. This ' +
                'option will be overriden by a custom background set through the ' +
                'game\\'s options menu. '
              )"
            >⚠️</span>
          </option-toggle>
        </option-toggle>

        <option-toggle storageKey="animatedBgEnabled" enabledIfKey="bgEnabled">
          <span title="Enables the custom animated background">
            Enable animated background
          </span>
          <option-toggle inline storageKey="animatedBgEnabled" mode="show">
            <option-toggle inline storageKey="bgEnabled" mode="show">
              <span
                class="warning-icon"
                :title="(
                  'Custom animated backgrounds are implemented differently from ' +
                  'regular backgrounds, and you can\\'t have more than one at a time. ' +
                  'Animated backgrounds are incompatible with normal backgrounds, ' +
                  'and TETR.IO PLUS custom backgrounds will not load while an ' +
                  'animated background is enabled.'
                )"
              >⚠️</span>
            </option-toggle>
          </option-toggle>
          <option-toggle inline storageKey="musicGraphBackground" mode="show">
            <span
              class="warning-icon"
              title="Incompatible with music graph backgrounds"
            >❌</span>
          </option-toggle>
        </option-toggle>


        <option-toggle
          storageKey="transparentBgEnabled"
          v-if="isElectron"
        >
          <span title="Makes the window transparent, showing other windows below it">
            Enable transparent window
          </span>
          <option-toggle inline storageKey="bgEnabled" mode="hide">
            <option-toggle inline storageKey="transparentBgEnabled" mode="show">
              <span
                class="warning-icon"
                :title="(
                  'Transparent window is incompatible with other background options. ' +
                  'Requires a RESTART of the client.'
                )"
              >⚠️</span>
            </option-toggle>
          </option-toggle>
        </option-toggle>

        <option-toggle storageKey="opaqueTransparentBackground">
          <span :title="(
            'This uses a black background instead of a transparent one when ' +
            'using animated backgrounds or the transparent window option. ' +
            'This allows setting the background opacity, but the in-game ' +
            'slider is inverted. 0% = background fully visible, 100% = ' +
            'background completely black.'
          )">
            Use opaque background
          </span>
        </option-toggle>

        <option-toggle storageKey="musicGraphBackground">
          <span :title="(
            'Enables setting backgrounds from the music graph. ' +
            'All normal backgrounds will be available in the music graph. ' +
            'This overrides all other possible background options.'
          )">
            Music graph backgrounds
          </span>
        </option-toggle>
      </div>

      <option-toggle storageKey="bgEnabled" mode="show">
        <hr />
        <div class="preview-group">
          <div v-if="backgrounds.length == 0">
            No custom backgrounds
          </div>
          <div class="background" v-else v-for="bg of backgrounds">
            <button @click="deleteBackground(bg)" title="Removes this background">
              Delete
            </button>
            <button @click="bg.preview = !bg.preview" title="Shows this background">
              Preview
            </button>
            <span class="bgName">
              {{ bg.background.filename }}
              <em v-if="bg.animated">animated</em>
            </span>
            <div v-if="bg.preview">
              <background-embed :background="bg.background"></background-embed>
            </div>
          </div>
        </div>
      </option-toggle>
    </div>
  `,
  data: () => ({
    cachedBackgrounds: null
  }),
  components: {
    BackgroundEmbed,
    OptionToggle
  },
  mounted() {
    this.reloadBackgrounds();
  },
  computed: {
    backgrounds() {
      if (!this.cachedBackgrounds) return [];
      return this.cachedBackgrounds;
    },
    isElectron() {
      return !!browser.electron;
    }
  },
  methods: {
    togglePreview(bg) {

    },
    reloadBackgrounds() {
      return browser.storage.local.get([
        'backgrounds',
        'animatedBackground'
      ]).then(res => {
        this.cachedBackgrounds = [];
        if (res.backgrounds) {
          this.cachedBackgrounds.push(...res.backgrounds.map(background => ({
            background: background,
            animated: false,
            preview: false
          })));
        }
        if (res.animatedBackground) {
          this.cachedBackgrounds.push({
            background: res.animatedBackground,
            animated: true,
            preview: false
          });
        }
      });
    },
    async openBgUploader() {
      let { name } = await browser.runtime.getBrowserInfo();
      if (name == 'Fennec') {
        browser.tabs.create({
          url: browser.extension.getURL('source/panels/bgpicker/index.html'),
          active: true
        });
      } else {
        browser.windows.create({
          type: 'detached_panel',
          url: browser.extension.getURL('source/panels/bgpicker/index.html'),
          width: 645,
          height: 425
        });
      }
    },
    deleteBackground(toDelete) {
      let delId = toDelete.background.id;

      browser.storage.local.get([
        'backgrounds',
        'animatedBackground'
      ]).then(({ backgrounds, animatedBackground }) => {
        if ((animatedBackground || {}).id == delId) {
          browser.storage.local.remove('animatedBackground');
          browser.storage.local.remove('background-' + animatedBackground.id)
        }

        backgrounds = (backgrounds || []).filter(bg => {
          if (bg.id == delId) {
            browser.storage.local.remove('background-' + bg.id);
            return false;
          }
          return true;
        });
        return browser.storage.local.set({ backgrounds });
      }).then(() => this.reloadBackgrounds());
    }
  }
}
