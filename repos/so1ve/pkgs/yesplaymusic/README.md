# YesPlayMusic 3.0

YesPlayMusic 3.0 is a local and plugin-based desktop music player. Online music
sources are provided by plugins in [`yesplaymusic-plugins`](../yesplaymusic-plugins/README.md).

## Using with plugins

Use `withPlugins` (or `.override { plugins = [ ... ]; }`):

```nix
home.packages = [
  (pkgs.so1ve.yesplaymusic.withPlugins (
    p: with p; [
      netease
      subsonic
    ]
  ))
];
```

On launch, the wrapper symlinks the selected plugins into
`${XDG_DATA_HOME:-$HOME/.local/share}/YesPlayMusic/plugins/` and tracks them in
`.nix-managed`. Removing a plugin from `withPlugins` cleans up its symlink on
the next launch while leaving plugin data (`plugin-data/`) and manually
installed plugin directories untouched.
