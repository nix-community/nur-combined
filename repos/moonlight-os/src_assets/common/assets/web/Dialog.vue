<script setup>
import { onBeforeUnmount, onMounted } from 'vue'

/** Modal dialog. Teleported to <body> so it escapes any transformed or
 *  overflow-clipped ancestor. */
defineProps({
  title: { type: String, default: null },
  open: { type: Boolean, default: false },
})

const emit = defineEmits(['close'])

function onKeydown(event) {
  if (event.key === 'Escape') emit('close')
}

onMounted(() => document.addEventListener('keydown', onKeydown))
onBeforeUnmount(() => document.removeEventListener('keydown', onKeydown))
</script>

<template>
  <Teleport to="body">
    <Transition name="md-dialog-fade">
      <div v-if="open" class="md-scrim" @click="emit('close')"></div>
    </Transition>
    <Transition name="md-dialog-pop">
      <div v-if="open" class="md-dialog" role="dialog" aria-modal="true">
        <header v-if="title || $slots.header" class="md-dialog__header">
          <h2 v-if="title" class="md-dialog__title">{{ title }}</h2>
          <slot name="header" />
          <button type="button" class="md-icon-button" :aria-label="$t('_common.cancel')" @click="emit('close')">
            <Icon name="close" />
          </button>
        </header>
        <div class="md-dialog__body"><slot /></div>
        <div v-if="$slots.actions" class="md-dialog__actions"><slot name="actions" /></div>
      </div>
    </Transition>
  </Teleport>
</template>

<style scoped>
.md-dialog-fade-enter-active,
.md-dialog-fade-leave-active {
  transition: opacity var(--md-sys-motion-spring-default-effects);
}

.md-dialog-fade-enter-from,
.md-dialog-fade-leave-to {
  opacity: 0;
}

.md-dialog-pop-enter-active {
  transition:
    opacity var(--md-sys-motion-spring-fast-effects),
    scale var(--md-sys-motion-spring-default-spatial);
}

.md-dialog-pop-leave-active {
  transition:
    opacity var(--md-sys-motion-spring-fast-effects),
    scale var(--md-sys-motion-spring-fast-effects);
}

.md-dialog-pop-enter-from,
.md-dialog-pop-leave-to {
  opacity: 0;
  scale: 0.85;
}
</style>
