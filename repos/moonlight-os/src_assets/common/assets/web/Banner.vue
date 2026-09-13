<script setup>
/** Inline status message. Colour comes from the matching container role pair,
 *  so text contrast holds in both schemes without per-variant overrides. */
const props = defineProps({
  variant: { type: String, default: 'neutral' },  // neutral | info | success | warning | error
  icon: { type: String, default: null },
})

const DEFAULT_ICONS = {
  neutral: 'info',
  info: 'info',
  success: 'check_circle',
  warning: 'warning',
  error: 'error',
}

const iconName = () => props.icon ?? DEFAULT_ICONS[props.variant] ?? 'info'
</script>

<template>
  <div class="md-banner" :class="variant !== 'neutral' && `md-banner--${variant}`" role="status">
    <Icon class="md-banner__icon" :name="iconName()" filled />
    <div class="md-banner__text"><slot /></div>
    <slot name="action" />
  </div>
</template>
