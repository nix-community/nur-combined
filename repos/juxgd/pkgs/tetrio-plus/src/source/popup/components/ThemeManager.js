const html = arg => arg.join(''); // NOOP, for editor integration.

export default {
  template: html`
    <div title="Changes the look of TETR.IO PLUS based on your browser theme. May look awful with some themes.">
      <input type="checkbox" v-model="enableTheming" />
      <label>Use browser themes</label>
    </div>
  `,
  data: () => ({
    theme: null,
    cache: {
      enableTheming: null
    }
  }),
  computed: {
    enableTheming: {
      get() {
        browser.storage.local.get('enableTheming').then(({ enableTheming }) => {
          if (enableTheming === undefined || enableTheming === null)
            enableTheming = true;
          if (this.cache.enableTheming != enableTheming)
            this.cache.enableTheming = enableTheming;
        });
        return this.cache.enableTheming;
      },
      set(val) {
        browser.storage.local.set({ enableTheming: val }).then(() => {
          this.cache.enableTheming = val;
        });
      }
    }
  },
  watch: {
    enableTheming(val) {
      this.applyTheme(val ? this.theme : null);
    },
    theme(theme) {
      this.applyTheme(this.enableTheming ? theme : null);
    }
  },
  methods: {
    applyTheme(theme) {
      console.log("Theme update", theme);

      if (!theme || !theme.colors) {
        document.body.style.setProperty('--bg', null);
        document.body.style.setProperty('--text', null);
        document.body.style.setProperty('--border', null);
        document.body.style.setProperty('--accent', null);
        document.body.classList.toggle('themed', false);
        return;
      }

      document.body.style.setProperty('--bg', theme.colors.popup);
      document.body.style.setProperty('--text', theme.colors.popup_text);
      document.body.style.setProperty('--border', theme.colors.popup_border);
      let accent = theme.colors.popup_highlight_text || theme.colors.popup_text;
      document.body.style.setProperty('--accent', accent);
      document.body.classList.toggle('themed', true);
    },
    onThemeUpdate({ theme, windowId }) {
      if (windowId) return;
      this.theme = theme;
    }
  },
  beforeMount() {
    browser.theme.getCurrent().then(theme => this.theme = theme);
    browser.theme.onUpdated.addListener(evt => this.onThemeUpdate(evt));
  },
  beforeDestroy() {
    browser.theme.onUpdated.removeListener(this.onThemeUpdate);
  }
}
