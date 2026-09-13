import i18n from './locale'
import Icon from './Icon.vue'
import { loadAutoTheme } from './theme'

// The stored preference is also applied inline in template_header.html so the
// first paint is already in the right scheme; this covers navigations that
// restore from bfcache with a stale attribute.
loadAutoTheme()

export function initApp(app, config) {
  app.component('Icon', Icon)

  // Wait for locale initialization, then render.
  i18n().then(i18n => {
    app.use(i18n);
    app.provide('i18n', i18n.global)
    app.mount('#app');
    if (config) {
      config(app)
    }
  });
}
