# Rofi Configuration

This directory contains the configuration for Rofi, a window switcher, application launcher, and dmenu replacement.

## Theme

The theme is defined in `theme.rasi`. It is a custom theme that provides a modern and clean look.

### Enabling Icons

To enable icons in the application launcher, you need to run Rofi with the `-show-icons` and `-icon-theme` flags. For example:

```bash
rofi -show-icons -icon-theme 'Papirus' -show drun
```

You can replace `'Papirus'` with the name of your preferred icon theme.
