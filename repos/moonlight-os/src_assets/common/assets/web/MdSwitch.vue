<script setup>
const model = defineModel({ type: Boolean, default: false })

defineProps({
  id: { type: String, default: null },
  disabled: { type: Boolean, default: false },
})
</script>

<template>
  <span class="md-switch">
    <input
      type="checkbox"
      class="md-switch__input"
      role="switch"
      :id="id"
      :disabled="disabled"
      v-model="model"
    />
    <span class="md-switch__thumb">
      <Icon v-if="model" name="check" />
    </span>
  </span>
</template>
