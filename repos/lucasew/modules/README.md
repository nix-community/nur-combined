# Modot modules

Stuff under `modules/` is wired in via `modot.cue` (`input: "self:modules/..."`). The palette lives in `options.base16.palette` (with a leading `#`); the `base16-*` modules expose it as `options.base16_<app>.palette` and paint apps with it.

## New base16 module

```
modules/base16-{app}/
├── modot.cue
├── README.md          # optional, keep short
└── home/
    └── .config/{app}/
        └── something.tmpl
```

`modot.cue`:

```cue
package module

// options is the module's config schema. modot injects it as options.<name>
// in the shared options tree. Module names must be CUE identifiers, so use
// base16_gtk, not base16-gtk.
options: {
	palette: options.base16.palette
}

// Contributions are top-level and unify into the global config.
file: home: {
	".config/{app}/something": {
		type: "toml"
		values: {
			color: options.base16.palette.base0D
		}
	}
}
```

A `base16-<app>` module copies the palette into its own options
(`palette: options.base16.palette`) and overrides entries when the app needs a
different mapping. Templates read the app's copy from
`options.base16_<app>.palette`, which already carries the leading `#`.
Notification driver weights live in the global prelude, so modules do not
repeat them.

Dest files can live in `file` (`docs/specs/file-spine.md` in modot) instead of
templates. Enable the module in `modot.cue`.

Enable in `modot.cue`:

```cue
"base16-{app}": {input: "self:modules/base16-{app}", enable: true}
```

Colors in templates:

```go
{{- $base16 := .root.modules.base16.config }}
color: #{{ $base16.base00 }}
```

Check with `modot home plan`, then `modot home apply`.

## `.d.tmpl` dirs

When one output file needs pieces from different places (bindings here, colors there), use a directory named `something.d.tmpl/`. Modot concatenates its files in alpha order into `something`.

Number prefixes set order: `00-` early, `10-` base, `50-` theme, `90-` late.

tmux:

```
config/.config/tmux/tmux.conf.d.tmpl/10-base.conf
modules/base16-tmux/home/.config/tmux/tmux.conf.d.tmpl/50-base16-theme.conf.tmpl
-> ~/.config/tmux/tmux.conf
```

Use it when more than one module touches the same file. If one module owns the whole config, a plain `.tmpl` is enough.

## Palette (`base00`-`base0F`)

| Slot   | Usual role                          |
|--------|-------------------------------------|
| base00 | background                          |
| base01 | lighter bg (status, line numbers)   |
| base02 | selection bg                        |
| base03 | comments / faint UI                 |
| base04 | dim foreground                      |
| base05 | default foreground                  |
| base06 | bright foreground                   |
| base07 | light bg (mostly unused in dark)    |
| base08 | red (error, urgent)                 |
| base09 | orange (warn, modified)             |
| base0A | yellow                              |
| base0B | green (ok, additions)               |
| base0C | cyan                                |
| base0D | blue (accent, active)               |
| base0E | purple                              |
| base0F | brown / deprecated                  |

Defined in `modules/base16/modot.cue` as `options.mode` plus `options.palette`. Values are set in `modot.cue`.

## Shapes that already exist here

- One file, module owns it: `base16-rofi` -> `theme.rasi.tmpl`, `base16-dunst` -> `dunstrc.tmpl`
- Splice into a shared file: `base16-tmux`, `base16-shell` (`.d.tmpl`)
- Several paths: `base16-gtk` (adw-gtk3 CSS overrides + GTK2 legacy + qt5ct/qt6ct)

## Modules in this repo

- `base16` - palette + a few driver weights
- `base16-shell`, `base16-sway`, `base16-swaylock`, `base16-helix`, `base16-vscode`
- `base16-gtk`, `base16-rofi`, `base16-dunst`, `base16-tmux`, `base16-opencode`, `base16-herdr`, `base16-grok`
- also non-theme: `fontconfig`, `mise`, `script-directory`, `webapp`
