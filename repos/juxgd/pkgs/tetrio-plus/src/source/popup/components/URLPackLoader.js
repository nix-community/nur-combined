import OptionToggle from './OptionToggle.js'
const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <div>
      <option-toggle inline storageKey="allowURLPackLoader">
        <span :title="(
          'Allows loading content packs with query parameters on the ' +
          'tetrio site. No confirmation prompt will be given when ' +
          'loading content packs in this manner!'
        )">
          Allow loading content packs by URL
        </span>
      </option-toggle>
      <option-toggle inline storageKey="allowURLPackLoader" mode="show">
        <button @click="editing = true">Edit</button>
      </option-toggle>
      <option-toggle
        storageKey="allowURLPackLoader"
        mode="show"
        style="margin-left: 24px"
        v-if="editing"
      >
        Domain whitelist<br/>
        <textarea cols="30" rows="3" v-model.trim="domains">
        </textarea><br/>
        <input type="checkbox" v-model="allowSaving"/>
        I know what I'm doing
        <button @click="save" v-if="allowSaving">Save</button>
      </option-toggle>
    </div>
  `,
  components: { OptionToggle },
  mounted() {
    browser.storage.local.get('whitelistedLoaderDomains').then(cfg => {
      this.domains = (cfg.whitelistedLoaderDomains || []).join("\n");
    });
  },
  data: () => ({
    domains: "",
    allowSaving: false,
    editing: false
  }),
  methods: {
    save() {
      browser.storage.local.set({
        whitelistedLoaderDomains: this.domains.split("\n")
      });
      this.editing = false
    }
  }
}
