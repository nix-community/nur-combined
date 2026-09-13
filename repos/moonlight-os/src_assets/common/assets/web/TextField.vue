<script setup>
/**
 * Material 3 filled text field.
 *
 * Filled rather than outlined on purpose: these forms sit on tinted cards, and
 * the filled container reads as an editable surface without needing the notched
 * outline. The floating label is driven by :placeholder-shown, so an input with
 * no placeholder of its own still gets a blank one.
 */
const model = defineModel({ default: '' })

defineOptions({ inheritAttrs: false })

const props = defineProps({
  id: { type: String, default: null },
  label: { type: String, default: null },
  type: { type: String, default: 'text' },
  placeholder: { type: String, default: null },
  supporting: { type: String, default: null },
  monospace: { type: Boolean, default: false },
  dense: { type: Boolean, default: false },
  error: { type: Boolean, default: false },
  disabled: { type: Boolean, default: false },
})

const slots = defineSlots()
</script>

<template>
  <div
    class="md-field"
    :class="{
      'md-field--dense': dense,
      'md-field--error': error,
      'md-field--bare': !label,
    }"
  >
    <div class="md-field__box">
      <input
        class="md-field__input"
        :class="{ monospace }"
        :id="id"
        :type="type"
        :disabled="disabled"
        :placeholder="placeholder || ' '"
        v-model="model"
        v-bind="$attrs"
      />
      <label v-if="label" class="md-field__label" :for="id">{{ label }}</label>
      <span v-if="slots.trailing" class="md-field__trailing"><slot name="trailing" /></span>
    </div>
    <div v-if="supporting || slots.supporting" class="md-field__supporting">
      <template v-if="supporting">{{ supporting }}</template>
      <slot name="supporting" />
    </div>
  </div>
</template>
