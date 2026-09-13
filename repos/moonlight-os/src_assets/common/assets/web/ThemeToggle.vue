<script setup>
import { onBeforeUnmount, onMounted, ref } from 'vue'
import { applyTheme, getStoredTheme, setStoredTheme } from './theme'

const OPTIONS = [
  { value: 'light', icon: 'light_mode', label: 'navbar.theme_light' },
  { value: 'dark', icon: 'dark_mode', label: 'navbar.theme_dark' },
  { value: 'auto', icon: 'contrast', label: 'navbar.theme_auto' },
]

const open = ref(false)
const current = ref(getStoredTheme())
const root = ref(null)

const activeIcon = () => OPTIONS.find(o => o.value === current.value)?.icon ?? 'contrast'

function choose(theme) {
  current.value = theme
  setStoredTheme(theme)
  applyTheme(theme)
  open.value = false
}

function onDocumentPointerDown(event) {
  if (root.value && !root.value.contains(event.target)) {
    open.value = false
  }
}

function onKeydown(event) {
  if (event.key === 'Escape') {
    open.value = false
  }
}

// "auto" has to keep following the OS while the page stays open.
const media = window.matchMedia('(prefers-color-scheme: dark)')
const onSchemeChange = () => {
  if (current.value === 'auto') applyTheme('auto')
}

onMounted(() => {
  applyTheme(current.value)
  media.addEventListener('change', onSchemeChange)
  document.addEventListener('pointerdown', onDocumentPointerDown)
  document.addEventListener('keydown', onKeydown)
})

onBeforeUnmount(() => {
  media.removeEventListener('change', onSchemeChange)
  document.removeEventListener('pointerdown', onDocumentPointerDown)
  document.removeEventListener('keydown', onKeydown)
})
</script>

<template>
  <div class="md-menu-anchor" ref="root">
    <button
      type="button"
      class="md-icon-button"
      :aria-label="$t('navbar.toggle_theme')"
      :aria-expanded="open"
      aria-haspopup="menu"
      @click="open = !open"
    >
      <Icon :name="activeIcon()" />
    </button>
    <Transition name="md-menu-pop">
      <ul v-if="open" class="md-menu" role="menu">
        <li v-for="option in OPTIONS" :key="option.value">
          <button
            type="button"
            role="menuitemradio"
            :aria-checked="current === option.value"
            class="md-menu-item"
            :class="{ 'md-menu-item--active': current === option.value }"
            @click="choose(option.value)"
          >
            <Icon :name="option.icon" :filled="current === option.value" />
            {{ $t(option.label) }}
          </button>
        </li>
      </ul>
    </Transition>
  </div>
</template>

<style scoped>
.md-menu {
  list-style: none;
  margin: 0;
}

.md-menu-pop-enter-active {
  transition:
    opacity var(--md-sys-motion-spring-fast-effects),
    scale var(--md-sys-motion-spring-fast-spatial);
}

.md-menu-pop-leave-active {
  transition:
    opacity var(--md-sys-motion-spring-fast-effects),
    scale var(--md-sys-motion-spring-fast-effects);
}

.md-menu-pop-enter-from,
.md-menu-pop-leave-to {
  opacity: 0;
  scale: 0.9;
}
</style>
