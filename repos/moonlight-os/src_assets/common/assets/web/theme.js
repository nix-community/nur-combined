/**
 * Colour scheme preference.
 *
 * Three states: an explicit light/dark choice stamps `data-theme` on the root
 * element, and "auto" removes it so the tokens fall through to the
 * prefers-color-scheme block in styles/tokens.css.
 */

const STORAGE_KEY = 'theme'

export const THEMES = ['light', 'dark', 'auto']

export function getStoredTheme() {
  const stored = localStorage.getItem(STORAGE_KEY)
  return THEMES.includes(stored) ? stored : 'auto'
}

export function setStoredTheme(theme) {
  localStorage.setItem(STORAGE_KEY, theme)
}

export function applyTheme(theme) {
  if (theme === 'light' || theme === 'dark') {
    document.documentElement.setAttribute('data-theme', theme)
  } else {
    document.documentElement.removeAttribute('data-theme')
  }
}

/**
 * Applies the stored preference and keeps "auto" tracking the OS.
 * Safe to call more than once per page.
 */
export function loadAutoTheme() {
  applyTheme(getStoredTheme())
}
