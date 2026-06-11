const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <img class="custom-background" :src="src" v-if="isImage"></img>
    <video class="custom-background" :src="src" autoplay loop muted v-else>
    </video>
  `,
  props: ['background'],
  data: () => ({
    src: null
  }),
  computed: {
    isImage() {
      return !(
        this.background.filename.endsWith('webm') ||
        this.background.filename.endsWith('mp4')
      );
    }
  },
  watch: {
    'background.id': {
      immediate: true,
      handler(val) {
        let key = 'background-' + val;
        browser.storage.local.get(key).then(result => {
          this.src = result[key];
        });
      }
    }
  }
}
