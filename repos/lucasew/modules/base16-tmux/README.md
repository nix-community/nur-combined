# base16-tmux

Theme chunk only. Dropped into the shared `tmux.conf.d.tmpl` tree as `50-base16-theme.conf.tmpl` so bindings stay in `config/`. Needs `base16`. How `.d.tmpl` works: [../README.md](../README.md).

Output is `~/.config/tmux/tmux.conf` (concat of all pieces).

Colors: status bg `base00`, idle borders/windows `base01`, current/copy `base02`, text `base04`/`base05`, accent `base0D`.

Reload: `tmux source-file ~/.config/tmux/tmux.conf` or prefix+`r`.
