const html = arg => arg.join(''); // NOOP, for editor integration.
import OptionToggle from './OptionToggle.js';

export default {
  template: html`
    <div class="component-wrapper">
      <div class="control-group">
        <button @click="openImageChanger" title="Opens the skin changer window">
          Change skin
        </button>
        <button @click="resetSkin" title="Removes the existing custom skin">
          Remove skin
        </button>
      </div>

      <div class="preview-group">
        <img
          title="This is the current block skin you are using."
          class="skin"
          :src="skinUrl"
          v-if="skinUrl">
        <div class="no-skin" v-else>
          No skin set
        </div>
      </div>
      <option-toggle storageKey="advancedSkinLoading">
        <span :title="(
          'This option is required for animated skins, but is more ' +
          'likely to break.'
        )">
          Enable animated skin support patch
        </span>
      </option-toggle>
      <option-toggle storageKey="forceNearestScaling">
        <span :title="(
          'Turns off texture filtering for TETR.IO globally. Makes skins ' +
          'sharper at the expense of overall visual quality.'
        )">
          Force nearest-neighbor scaling
        </span>
      </option-toggle>
    </div>
  `,
  components: { OptionToggle },
  data: () => ({
    skinUrl: null
  }),
  mounted() {
    this.loadSkin();
  },
  methods: {
    loadSkin() {
      this.skinUrl = null;
      browser.storage.local.get(['skin', 'ghost']).then(async ({ skin, ghost }) => {
        if (!skin && !ghost) return null;

        let canvas = document.createElement('canvas');
        let ctx = canvas.getContext('2d');
        canvas.width = 372;
        canvas.height = 30;

        async function makeImage(src) {
          if (!src) return null;
          let img = new Image();
          img.crossOrigin = 'Anonymous'; // WHY?? It's a *data url*
          img.src = src;
          await new Promise(r => img.onload = r);
          return img;
        }

        let sources = {
          ghost: await makeImage(ghost),
          skin: await makeImage(skin)
        };

        let bs = 96; // block size
        let blocks = [
          { source:  'skin', x: bs* 0, y: bs* 3 }, // z, *3 = get all-borders block
          { source:  'skin', x: bs* 4, y: bs* 3 }, // l
          { source:  'skin', x: bs* 8, y: bs* 3 }, // o
          { source:  'skin', x: bs*12, y: bs* 3 }, // s
          { source:  'skin', x: bs* 0, y: bs* 9 }, // i
          { source:  'skin', x: bs* 4, y: bs* 9 }, // j
          { source:  'skin', x: bs* 8, y: bs* 9 }, // t
          { source: 'ghost', x: bs* 0, y: bs* 3 }, // ghost
          { source:  'skin', x: bs*12, y: bs* 9 }, // hold
          { source:  'skin', x: bs*16, y: bs* 3 }, // garbage
          { source:  'skin', x: bs*16, y: bs* 7 }, // dark garbage
          { source: 'ghost', x: bs* 4, y: bs* 3 }, // topout
        ];
        for (let i = 0; i < 12; i++) {
          let { source, x, y } = blocks[i];
          if (!sources[source]) continue;
          ctx.drawImage(
            sources[source],
            x, y, bs, bs,
            i*31, 0, 30, 30
          );
        }

        this.skinUrl = canvas.toDataURL('image/png');
      });
    },
    async resetSkin() {
      await browser.storage.local.remove([
        'skin', 'skinAnim', 'skinAnimMeta',
        'ghost', 'ghostAnim', 'ghostAnimMeta'
      ]);
      await this.loadSkin();
    },
    async open(url) {
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
    },
    async openImageChanger() {
      await this.open('source/panels/skinpicker/index.html');
    }
  }
}
