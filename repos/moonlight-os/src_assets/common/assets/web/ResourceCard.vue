<script setup>
const resources = [
  {
    icon: 'forum',
    label: 'resource_card.github_discussions',
    href: 'https://github.com/ClassicOldSong/Apollo/discussions',
  },
  {
    icon: 'menu_book',
    label: 'resource_card.github_wiki',
    href: 'https://github.com/ClassicOldSong/Apollo/wiki',
  },
  {
    icon: 'troubleshoot',
    label: 'resource_card.github_stuttering_clinic',
    href: 'https://github.com/ClassicOldSong/Apollo/wiki/Stuttering-Clinic',
  },
]

const legal = [
  {
    icon: 'gavel',
    label: 'resource_card.license',
    href: 'https://github.com/ClassicOldSong/Apollo/blob/master/LICENSE',
  },
  {
    icon: 'description',
    label: 'resource_card.third_party_notice',
    href: 'https://github.com/ClassicOldSong/Apollo/blob/master/NOTICE',
  },
]
</script>

<template>
  <section class="md-card md-card--elevated">
    <div class="md-card__body">
      <div class="flex items-center gap-3">
        <span class="md-card__badge"><Icon name="menu_book" filled /></span>
        <h2 class="md-card__title">{{ $t('resource_card.resources') }}</h2>
      </div>
      <p class="md-card__supporting">{{ $t('resource_card.resources_desc') }}</p>
      <div class="flex flex-wrap gap-2 mt-5">
        <a
          v-for="item in resources"
          :key="item.href"
          class="md-button md-button--tonal"
          :href="item.href"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Icon :name="item.icon" />{{ $t(item.label) }}
        </a>
      </div>

      <hr class="md-divider mt-6 mb-5" />

      <h3 class="md-title-medium">{{ $t('resource_card.legal') }}</h3>
      <p class="md-card__supporting">{{ $t('resource_card.legal_desc') }}</p>
      <div class="flex flex-wrap gap-2 mt-4">
        <a
          v-for="item in legal"
          :key="item.href"
          class="md-button md-button--outlined"
          :href="item.href"
          target="_blank"
          rel="noopener noreferrer"
        >
          <Icon :name="item.icon" />{{ $t(item.label) }}
        </a>
      </div>
    </div>
  </section>
</template>
