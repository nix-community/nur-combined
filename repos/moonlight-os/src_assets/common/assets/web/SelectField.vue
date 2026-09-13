<script setup>
/** Material 3 filled select. Wraps a native <select> so keyboard and mobile
 *  pickers keep working; only the chrome is ours. */
const model = defineModel({ default: '' })

defineOptions({ inheritAttrs: false })

defineProps({
  id: { type: String, default: null },
  label: { type: String, default: null },
  supporting: { type: String, default: null },
  disabled: { type: Boolean, default: false },
})

const slots = defineSlots()
</script>

<template>
  <div class="md-field md-field--populated" :class="{ 'md-field--bare': !label }">
    <div class="md-field__box">
      <select
        class="md-field__select"
        :id="id"
        :disabled="disabled"
        v-model="model"
        v-bind="$attrs"
      >
        <slot />
      </select>
      <label v-if="label" class="md-field__label" :for="id">{{ label }}</label>
      <Icon class="md-field__arrow" name="expand_more" />
    </div>
    <div v-if="supporting || slots.supporting" class="md-field__supporting">
      <template v-if="supporting">{{ supporting }}</template>
      <slot name="supporting" />
    </div>
  </div>
</template>
