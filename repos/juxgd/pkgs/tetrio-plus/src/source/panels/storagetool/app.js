const html = arg => arg.join('');
let app = new Vue({
  template: html`
    <div>
      ⚠️⚠️⚠️ Development/Debug tool ⚠️⚠️⚠️<br>
      Don't use unless <b>you</b> know what you're doing. This allows writing data
      unsanitized directly into storage, which has a cataclysmically high chance
      of breaking your game or bricking your TETR.IO PLUS install.<br>

      <div>
        <label for="key">Storage key</label>
        <input name="key" type="text" v-model="key" />
      </div>

      <div>
        <label for="file">Upload file</label>
        <input name="file" ref="file" type="file" @change="set" />
      </div>

      <div>{{ result }}</div>
    </div>
  `,
  data: {
    key: '',
    result: ''
  },
  methods: {
    async set() {
      if (!this.key) {
        this.result = `Please set a key first`;
      } else {
        let file = this.$refs.file.files[0];
        if (!file) return;

        let reader = new FileReader();
        await new Promise(res => {
          reader.addEventListener('load', res);
          reader.readAsDataURL(file);
        });
        browser.storage.local.set({ [this.key]: reader.result });
        this.result = `Key ${this.key} set to data url of length ${reader.result.length}!`;
      }

      // reset the handler
      this.$refs.file.type = '';
      this.$refs.file.type = 'file';
    }
  }
});
app.$mount('#app');
