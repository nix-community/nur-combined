# base16-gtk

Colors **adw-gtk3** (GTK3) and **libadwaita** (GTK4) from `modules.base16.config`.
Optional `base10`–`base17` slots use base24 fallbacks when unset. Needs `base16`
and the `adw-gtk3` package (see `nix/nodes/gui-common/gui.nix`).

Same approach as [Stylix GTK](https://github.com/nix-community/stylix/blob/master/modules/gtk/hm.nix):
keep the real theme engine, inject named colors into user CSS.

Writes:

- `~/.config/gtk-3.0/{gtk.css,settings.ini}`
- `~/.config/gtk-4.0/{gtk.css,settings.ini}`
- `~/.local/share/themes/base16/` (GTK2 legacy only)
- `~/.config/qt{5,6}ct/colors/base16.conf`

Config (`modules.base16-gtk.config`):

| key | default |
|-----|---------|
| `theme_name` | `adw-gtk3-dark` / `adw-gtk3` from `base16.dark_mode` |
| `icon_theme` | `workspaced-base16` |
| `font_name` | `Sans 10` |
| `cursor_theme` | `Adwaita` |
| `cursor_size` | `24` |
| `extra_css` | `""` appended to both `gtk.css` files |

Apply:

```bash
# drop stale home-manager/Stylix symlinks if present
rm -f ~/.config/gtk-3.0/gtk.css ~/.config/gtk-4.0/gtk.css

workspaced home apply
~/.dotfiles/bin/hooks/reload-gtk-theme
```

Restart long-lived GTK apps (or log out) if colors do not refresh.

Qt: in `qt5ct` / `qt6ct` → Appearance → color scheme `base16`.
