<script setup>
import { ref } from 'vue'

/** Expansion panel. Replaces the old Bootstrap accordion so no framework
 *  JavaScript is needed to open a section. */
const props = defineProps({
  title: { type: String, required: true },
  icon: { type: String, default: null },
  open: { type: Boolean, default: true },
})

const expanded = ref(props.open)
</script>

<template>
  <div class="md-expander" :class="{ 'md-expander--open': expanded }">
    <button
      type="button"
      class="md-expander__header"
      :aria-expanded="expanded"
      @click="expanded = !expanded"
    >
      <Icon v-if="icon" :name="icon" />
      <span class="flex-1">{{ title }}</span>
      <Icon class="md-expander__chevron" name="expand_more" />
    </button>
    <Transition name="md-expand">
      <div v-show="expanded" class="md-expander__body">
        <slot />
      </div>
    </Transition>
  </div>
</template>

<style scoped>
.md-expand-enter-active,
.md-expand-leave-active {
  overflow: hidden;
  transition:
    grid-template-rows var(--md-sys-motion-spring-default-spatial),
    opacity var(--md-sys-motion-spring-fast-effects);
}

.md-expand-enter-from,
.md-expand-leave-to {
  opacity: 0;
}
</style>
