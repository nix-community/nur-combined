import cacheStorage from './SharedCache.js';
const html = arg => arg.join(''); // NOOP, for editor integration.

/**
 * A watcher that ensures a value is set reactively
 * __ob__ is an interval vue value thats set on
 * objects made reactive.
 */
const ensureReactive = {
  immediate: true,
  handler(val) {
    this.$set(this.cache, val, this.cache[val]);
  }
};

export default {
  template: html`
    <div class="optionToggle" :style="style" @click="toggleValue">
      <template v-if="optionValue && mode == 'show'">
        <slot></slot>
      </template>
      <template v-else-if="!optionValue && mode == 'hide'">
        <slot></slot>
      </template>
      <template v-else-if="mode == 'toggle'">
        <input type="checkbox" v-model="optionValue" v-if="!disabled" />
        <input type="checkbox" value="false" v-else disabled />
        <slot></slot>
      </template>
    </div>
  `,
  props: {
    inline: {
      type: Boolean,
      default: false
    },
    /**
     * What storage key to use
     */
    storageKey: String,
    /**
     * Mode determines what this toggle does:
     * - toggle: Shows a checkbox that toggles the value
     * - show: Shows the content if the value is true
     * - hide: Hides the content if the value is true
     * - trigger: Emits a trigger 'trigger' event when the value is true
     */
    mode: {
      type: String,
      default: 'toggle'
    },
    /**
     * Checks another storage value to see if the checkbox should be disabled.
     * Toggle mode only.
     */
    enabledIfKey: {
      type: String,
      default: ""
    },
    /**
     * Inverts the enabled status of the checkbox based on enabledIfKey
     */
    invertEnabled: {
      type: Boolean,
      default: false
    }
  },
  data: () => ({
    cache: cacheStorage
  }),
  watch: {
    optionValue(val) {
      this.$emit('changed', val);
    },
    storageKey: ensureReactive,
    enabledIfKey: ensureReactive
  },
  methods: {
    toggleValue() {
      if (this.disabled) return;
      if (this.mode != 'toggle') return;
      this.optionValue = !this.optionValue;
      this.$emit('toggled');
    }
  },
  computed: {
    style() {
      if (this.inline)
        return { display: 'inline' };
      return {};
    },
    optionValue: {
      get() {
        browser.storage.local.get(this.storageKey).then(result => {
          let val = result[this.storageKey];
          if (this.cache[this.storageKey] != val) {
            this.cache[this.storageKey] = val;
            if (this.mode == 'trigger' && val)
              this.$emit('trigger', val);
          }
        });
        return this.cache[this.storageKey];
      },
      set(val) {
        browser.storage.local.set({ [this.storageKey]: val }).then(() => {
          this.cache[this.storageKey] = val;
          if (this.mode == 'trigger' && val)
            this.$emit('trigger', val);
        });
      }
    },
    disabled() {
      if (!this.enabledIfKey) return false;
      browser.storage.local.get(this.enabledIfKey).then(result => {
        this.cache[this.enabledIfKey] = result[this.enabledIfKey];
      });
      let value = this.cache[this.enabledIfKey];
      return this.invertEnabled ? !!value : !value;
    }
  }
}
