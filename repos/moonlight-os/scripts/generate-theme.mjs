/*
 * Regenerates the Material 3 colour roles baked into
 * src_assets/common/assets/web/styles/tokens.css.
 *
 * Run with the library available on the fly -- it is not a project dependency,
 * because the output is static and only changes when the brand does:
 *
 *   npm install --no-save @material/material-color-utilities
 *   node scripts/generate-theme.mjs
 *
 * The palettes are hand-set rather than derived wholesale from the seed. A
 * plain seeded scheme either drifts off-brand (the stock "expressive" variant
 * rotates Helios gold to purple) or leaves the tertiary a muddy olive, so:
 * primary tracks the brand gold, secondary is the warm amber beside it, and
 * tertiary is a deliberate cool teal that carries every informational accent.
 */

import {
  DynamicScheme,
  Hct,
  MaterialDynamicColors,
  TonalPalette,
  Variant,
  argbFromHex,
  hexFromArgb,
} from '@material/material-color-utilities'

const SEED = Hct.fromInt(argbFromHex('#FFC400'))

const palettes = {
  primaryPalette: TonalPalette.fromHueAndChroma(SEED.hue, 68),
  secondaryPalette: TonalPalette.fromHueAndChroma(58, 36),
  tertiaryPalette: TonalPalette.fromHueAndChroma(218, 42),
  neutralPalette: TonalPalette.fromHueAndChroma(SEED.hue, 5),
  neutralVariantPalette: TonalPalette.fromHueAndChroma(SEED.hue, 10),
}

const ROLES = [
  'primary', 'onPrimary', 'primaryContainer', 'onPrimaryContainer',
  'primaryFixed', 'primaryFixedDim', 'onPrimaryFixed', 'onPrimaryFixedVariant',
  'secondary', 'onSecondary', 'secondaryContainer', 'onSecondaryContainer',
  'secondaryFixed', 'secondaryFixedDim', 'onSecondaryFixed', 'onSecondaryFixedVariant',
  'tertiary', 'onTertiary', 'tertiaryContainer', 'onTertiaryContainer',
  'tertiaryFixed', 'tertiaryFixedDim', 'onTertiaryFixed', 'onTertiaryFixedVariant',
  'error', 'onError', 'errorContainer', 'onErrorContainer',
  'background', 'onBackground', 'surface', 'onSurface',
  'surfaceVariant', 'onSurfaceVariant', 'surfaceDim', 'surfaceBright',
  'surfaceContainerLowest', 'surfaceContainerLow', 'surfaceContainer',
  'surfaceContainerHigh', 'surfaceContainerHighest', 'surfaceTint',
  'outline', 'outlineVariant',
  'inverseSurface', 'inverseOnSurface', 'inversePrimary',
]

// M3 has no success role; this is a green harmonised toward the brand hue and
// mapped onto the standard container tones (40/100/90/10 light, 80/20/30/90 dark).
const SUCCESS = TonalPalette.fromHueAndChroma(134.3, 60)

const kebab = (role) => role.replace(/([a-z0-9])([A-Z])/g, '$1-$2').toLowerCase()

for (const isDark of [false, true]) {
  const scheme = new DynamicScheme({
    sourceColorHct: SEED,
    variant: Variant.VIBRANT,
    isDark,
    contrastLevel: 0,
    specVersion: '2025',
    platform: 'phone',
    ...palettes,
  })

  console.log(`/* ${isDark ? 'dark' : 'light'} */`)
  for (const role of ROLES) {
    console.log(`  --md-sys-color-${kebab(role)}: ${hexFromArgb(MaterialDynamicColors[role].getArgb(scheme))};`)
  }
  const tones = isDark ? [80, 20, 30, 90] : [40, 100, 90, 10]
  const names = ['success', 'on-success', 'success-container', 'on-success-container']
  names.forEach((name, i) => {
    console.log(`  --md-sys-color-${name}: ${hexFromArgb(SUCCESS.tone(tones[i]))};`)
  })
  console.log('')
}
