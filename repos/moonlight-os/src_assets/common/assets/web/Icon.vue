<script setup>
import codepoints from './icons.js'

/**
 * Material Symbols Rounded glyph.
 *
 * The bundled font is subset to the symbols listed in
 * scripts/build-material-symbols.py, and ligatures are stripped along with it
 * (every symbol name spells out of the same handful of letters, so keeping the
 * ligature tables would drag all ~4400 icons back in). Names are therefore
 * resolved to codepoints here instead of by the font.
 */
const props = defineProps({
  name: { type: String, required: true },
  filled: { type: Boolean, default: false },
  size: { type: String, default: null },  // sm | lg | xl
})

const glyph = codepoints[props.name]
if (!glyph) {
  console.warn(`Unknown icon "${props.name}" -- add it to scripts/build-material-symbols.py`)
}
</script>

<template>
  <span
    class="md-icon"
    :class="[filled && 'md-icon--filled', size && `md-icon--${size}`]"
    aria-hidden="true"
    translate="no"
  >{{ glyph }}</span>
</template>
