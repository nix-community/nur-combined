import OptionToggle from './OptionToggle.js'
const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <div>
      <option-toggle inline storageKey="enableCustomCss">
        <span title="Injects custom CSS into TETR.IO">
          Enable custom CSS
        </span>
      </option-toggle>
      <option-toggle inline storageKey="enableCustomCss" mode="show">
        <button @click="editing = true" :disabled="editing">Edit</button>
        <textarea name="css" v-model="css" cols="44" rows="5" v-if="editing" />
        <br>
        <button @click="save" v-if="editing">Save</button>
      </option-toggle>
    </div>
  `,
  components: { OptionToggle },
  mounted() {
    browser.storage.local.get('customCss').then(({ customCss }) => {
      this.css = customCss ?? '';
    });
  },
  data: () => ({
    editing: false,
    css: ""
  }),
  methods: {
    save() {
      browser.storage.local.set({
        customCss: this.css
      });
      this.editing = false;
    }
  }
}
