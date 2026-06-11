const html = arg => arg.join(''); // NOOP, for editor integration.
import TableView from './components/TableView.js';
import ListView from './components/ListView.js';

const app = new Vue({
  template: html`
    <div>
      <header>
        <button class="tab" v-for="itab of tabs" @click="tab = itab">
          {{ itab.name }}
        </button>
        <button @click="save">
          Save changes
        </button>
        <span style="color: red" v-if="builtinError">Failed to fetch override targets: {{builtinError}}</span>
        <span :style="{ opacity: saveOpacity }">
          Saved!
        </span>
      </header>
      <keep-alive>
        <component
          :is="tab.component"
          :music="music"
          :builtin="builtin"
          @save="save"
          @deleteSong="deleteSong"
        />
      </keep-alive>
    </div>
  `,
  data: {
    tabs: [
      { name: 'List View', component: ListView },
      { name: 'Table View', component: TableView }
    ],
    tab: null,
    music: [],
    builtin: null,
    builtinError: null,
    deleteOnSave: [],
    saveTimeout: null,
    saveOpacity: 0
  },
  created() {
    this.tab = this.tabs[0];
  },
  async mounted() {
    let cfg = await browser.storage.local.get('music');
    this.music = cfg.music || [];

    try {
      const rootUrl = browser.electron ? 'tetrio-plus://tetrio-plus/' : 'https://tetr.io/';
      let url = rootUrl + 'js/tetrio.js?tetrio-plus-bypass=true';
      let tetriojs = await (await fetch(url)).text();

      // most of this is stolen from `music-tetriojs-filter.js`
      let regex = /{"kuchu-toshi":{[^}]+}(?:,"?[^"]+"?:{[^}]+})+}/;
      let match = regex.exec(tetriojs);
      if (!match) throw new Error(`no match`);
      let sanitized = match[0]
        // replace minified constants
        .replace(/!0/g, 'true')
        .replace(/!1/g, 'false')
        // quote unquoted keys
        .replace(/(\s*?{\s*?|\s*?,\s*?)(['"])?([a-zA-Z0-9_]+)(['"])?:/g, '$1"$3":')
        // Add leading 0 to numbers, since json doesn't allow numbers to start with a dot
        .replace(/("[^"]+":)(\.\d+)/, (_, key, number) => key + '0' + number)
        // Fill in constants with whatever, we only really care about song names here
        .replace(/("[^"]+":)([A-Za-z\._]+)/g, (_, key, constant) => key + 'null')
        .replace(/"source":([^\d"},][^,}]+)/g, `"source": null`);
      console.log('attempting to parse sanitized builtins', sanitized);
      this.builtin = JSON.parse(sanitized);
      console.log('fetched builtins', this.builtin);
    } catch(ex) {
      this.builtinError = ex;
    }
  },
  methods: {
    async save() {
      try {
        await browser.storage.local.set({
          music: JSON.parse(JSON.stringify(this.music)) // de-Vue the object
        });
        await browser.storage.local.remove(this.deleteOnSave);
        this.deleteOnSave.length = 0;

        this.saveOpacity = 1.25;
        let timeout = setInterval(() => {
          this.saveOpacity -= 0.1;
          if (this.saveOpacity <= 0)
            clearTimeout(timeout);
        }, 50);
      } catch(ex) {
        console.error(ex);
        alert('Failed to save changes: ' + ex);
      }
    },
    deleteSong(song) {
      this.$emit('delete', song);
      this.music.splice(this.music.indexOf(song), 1);
      this.deleteOnSave.push('song-' + song.id);
    }
  }
})

app.$mount('#app');
window.app = app;
