import filehelper from '../../shared/filehelper.js';
import importer from '../../importers/import.js';
const html = arg => arg.join(''); // NOOP, for editor integration.

const app = new Vue({
  template: html`
    <div>
      <div>
        <fieldset>
          <legend>Loader</legend>
          <div>
            <input type="radio" :value="null" v-model="loader"/>
            Automatic
          </div>

          <div v-for="i of loaders">
            <input type="radio" :value="i" v-model="loader"/>
            {{ i.name }}: {{ i.desc }}
          </div>
        </fieldset>
      </div>
      <fieldset v-if="!loader || extrainputs.delay">
        <legend>Animated skin options</legend>
        <div>
          <input type="checkbox" v-model="overrideFPS" />
          Override framerate
        </div>
        <div>
          Delay (frames):
          <input type="number" v-model.number="delay" min="1" :disabled="!overrideFPS">
        </div>
        <div>
          <input type="checkbox" v-model="combine" />
          Combine frames
        </div>
      </fieldset>
      <fieldset>
        <legend>Upload</legend>
        <div>
          <input ref="files" type="file" accept="image/*" multiple />
        </div>
      </fieldset>
      <button @click="load">Set skin</button>
    </div>
  `,
  data: {
    loader: null,
    delay: 30,
    overrideFPS: false,
    combine: true,
    loaders: importer.skin.loaders.map(e => ({...e}))
  },
  computed: {
    extrainputs() {
      if (!this.loader) return {};
      return this.loader.extrainputs.reduce((obj, input) => {
        obj[input] = true;
        return obj;
      }, {});
    }
  },
  methods: {
    async load() {
      let files = await filehelper(this.$refs.files);
      console.log("Files", files);

      // Check if aspect ratios are valid
      if (!this.loader) {
        files: for (let file of files) {
          let aspect = file.image.width / file.image.height;

          let fmts = [];
          for (let [name, ratio] of importer.skin.knownAspectRatios) {
            fmts.push(`${name} format is ${ratio}`);
            if (aspect == ratio) continue files;
          }

          alert(
            `Unknown aspect ratio ${aspect}. ` +
            fmts.join(', ') + '. This skin isn\'t ' +
            'formatted correctly, but choosing the closest option may work.'
          );
          return;
        }
      }

      try {
        let opts = {
          delay: this.overrideFPS ? this.delay : 0,
          combine: this.combine
        };
        console.log(opts);

        this.loader
          ? await this.loader.load(files, browser.storage.local, opts)
          : await importer.skin.automatic(files, browser.storage.local, opts);
        alert('Skin set!');
      } catch(ex) {
        alert(ex.toString());
        console.error(ex);
      }
    }
  }
});
window.app = app;
app.$mount('#app');
