<script setup>
const clients = [
  {
    platform: 'Android',
    icon: 'android',
    name: 'Artemis',
    link: 'https://github.com/ClassicOldSong/moonlight-android'
  },
  {
    platform: 'iOS',
    icon: 'devices',
    name: 'Coming soon...',
    link: ''
  },
  {
    platform: 'Desktop',
    icon: 'desktop_windows',
    name: 'Coming soon...',
    link: ''
  }
]
</script>

<template>
  <section class="md-card md-card--elevated">
    <div class="md-card__body">
      <div class="flex items-center gap-3">
        <span class="md-card__badge"><Icon name="devices" filled /></span>
        <h2 class="md-card__title">{{ $t('client_card.clients') }}</h2>
      </div>
      <p class="md-card__supporting">{{ $t('client_card.clients_desc') }}</p>

      <div class="grid grid-auto mt-5">
        <component
          v-for="{ platform, icon, name, link } of clients"
          :key="platform"
          :is="link ? 'a' : 'div'"
          class="helios-client"
          :class="{ 'helios-client--available': link }"
          :href="link || null"
          :target="link ? '_blank' : null"
          rel="noopener noreferrer"
        >
          <Icon :name="icon" size="lg" :filled="!!link" />
          <span class="helios-client__text">
            <span class="md-title-small">{{ platform }}</span>
            <span class="md-body-small text-muted">{{ name }}</span>
          </span>
          <Icon v-if="link" name="open_in_new" size="sm" />
        </component>
      </div>

      <p class="md-body-small text-muted mt-4 mb-0">* {{ $t('client_card.generic_moonlight_clients_desc') }}</p>
    </div>
  </section>
</template>

<style scoped>
.helios-client {
  display: flex;
  align-items: center;
  gap: 0.75rem;
  padding: 1rem;
  border-radius: var(--md-sys-shape-corner-md);
  background-color: var(--md-sys-color-surface-container);
  color: var(--md-sys-color-on-surface-variant);
  text-decoration: none;
  transition:
    background-color var(--md-sys-motion-spring-default-effects),
    translate var(--md-sys-motion-spring-fast-spatial);
}

.helios-client--available {
  background-color: var(--md-sys-color-tertiary-container);
  color: var(--md-sys-color-on-tertiary-container);
}

.helios-client--available:hover {
  translate: 0 -2px;
}

.helios-client__text {
  display: flex;
  flex-direction: column;
  flex: 1 1 auto;
  min-width: 0;
}

.helios-client__text .text-muted {
  color: inherit;
  opacity: 0.75;
}
</style>
