<script setup>
import { computed, onBeforeUnmount, onMounted, ref } from 'vue'
import ThemeToggle from './ThemeToggle.vue'

/**
 * Application shell: navigation rail on wide viewports, modal navigation
 * drawer below 905px, and a top app bar that lifts once the page scrolls.
 *
 * Pages wrap their content in this instead of dropping a nav bar above it, so
 * the frame owns the layout and every page picks up the same behaviour.
 */
const props = defineProps({
  page: { type: String, default: null },
  title: { type: String, default: null },
})

const NAV = [
  { id: 'home', href: './', icon: 'sunny', label: 'navbar.home' },
  { id: 'pin', href: './pin', icon: 'vpn_key', label: 'navbar.pin' },
  { id: 'apps', href: './apps', icon: 'widgets', label: 'navbar.applications' },
  { id: 'config', href: './config', icon: 'tune', label: 'navbar.configuration' },
  { id: 'password', href: './password', icon: 'password', label: 'navbar.password' },
  { id: 'troubleshooting', href: './troubleshooting', icon: 'troubleshoot', label: 'navbar.troubleshoot' },
]

const drawerOpen = ref(false)
const scrolled = ref(false)

// Fall back to the URL when a page does not name itself, so the rail still
// highlights correctly.
const activeId = computed(() => {
  if (props.page) return props.page
  const path = window.location.pathname.replace(/\/$/, '')
  const match = NAV.find(item => path.endsWith(item.href.replace('./', '/')))
  return match ? match.id : 'home'
})

const onScroll = () => { scrolled.value = window.scrollY > 4 }

onMounted(() => {
  window.addEventListener('scroll', onScroll, { passive: true })
  onScroll()
})

onBeforeUnmount(() => window.removeEventListener('scroll', onScroll))
</script>

<template>
  <div class="helios-shell">
    <nav class="helios-rail" :aria-label="$t('navbar.navigation')">
      <a class="helios-rail__brand" href="./" title="Helios">
        <img src="/images/logo-helios-45.png" alt="Helios" />
      </a>
      <div class="helios-rail__items">
        <a
          v-for="item in NAV"
          :key="item.id"
          class="md-nav-item"
          :class="{ 'md-nav-item--active': item.id === activeId }"
          :href="item.href"
          :aria-current="item.id === activeId ? 'page' : null"
        >
          <span class="md-nav-item__indicator"><Icon :name="item.icon" /></span>
          <span class="md-nav-item__label">{{ $t(item.label) }}</span>
        </a>
      </div>
    </nav>

    <div class="helios-main">
      <header class="helios-topbar" :class="{ 'helios-topbar--raised': scrolled }">
        <button
          type="button"
          class="md-icon-button helios-menu-button"
          :aria-label="$t('navbar.menu')"
          @click="drawerOpen = true"
        >
          <Icon name="menu" />
        </button>
        <span class="helios-topbar__brand helios-mark helios-mark--sm">
          <img src="/images/logo-helios-45.png" alt="Helios" />
        </span>
        <h1 class="helios-topbar__title">
          <slot name="title">{{ title }}</slot>
        </h1>
        <slot name="actions" />
        <ThemeToggle />
      </header>

      <main class="helios-content">
        <slot />
      </main>
    </div>

    <Teleport to="body">
      <Transition name="helios-scrim">
        <div v-if="drawerOpen" class="md-scrim" @click="drawerOpen = false"></div>
      </Transition>
      <Transition name="helios-drawer">
        <nav v-if="drawerOpen" class="helios-drawer" :aria-label="$t('navbar.navigation')">
          <div class="helios-drawer__header">
            <span class="helios-mark helios-mark--sm"><img src="/images/logo-helios-45.png" alt="" /></span>
            <span class="helios-drawer__title">Helios</span>
          </div>
          <a
            v-for="item in NAV"
            :key="item.id"
            class="md-drawer-item"
            :class="{ 'md-drawer-item--active': item.id === activeId }"
            :href="item.href"
          >
            <Icon :name="item.icon" />
            {{ $t(item.label) }}
          </a>
        </nav>
      </Transition>
    </Teleport>
  </div>
</template>

<style scoped>
.helios-menu-button {
  display: inline-flex;
}

@media (min-width: 905px) {
  .helios-menu-button {
    display: none;
  }
}

.helios-scrim-enter-active,
.helios-scrim-leave-active {
  transition: opacity var(--md-sys-motion-spring-default-effects);
}

.helios-scrim-enter-from,
.helios-scrim-leave-to {
  opacity: 0;
}

.helios-drawer-enter-active {
  transition: translate var(--md-sys-motion-spring-default-spatial);
}

.helios-drawer-leave-active {
  transition: translate var(--md-sys-motion-spring-fast-effects);
}

.helios-drawer-enter-from,
.helios-drawer-leave-to {
  translate: -100% 0;
}
</style>
