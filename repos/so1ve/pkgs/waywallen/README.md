# Waywallen

## Plugins

Select packaged plugins with `override`:

```nix
pkgs.nur.repos.so1ve.waywallen.override {
  plugins = [ "open-wallpaper-engine" ];
}
```

Packaged plugin names are exposed in `waywallen.availablePlugins`. The
`plugins` list also accepts `{ id, src }` entries where `src` is a
Waywallen plugin ZIP and `id` matches its manifest. To track a plugin's GitHub
releases, add its metadata and asset patterns to [source.ts](source.ts) and
run `nix run .#update -- waywallen`. The updater generates the available plugin
catalog and a separate version and hashes for each plugin.

The Plugins page also accepts ZIPs in the running app. User-installed plugins
live in `$XDG_DATA_HOME/waywallen/plugins` (usually
`~/.local/share/waywallen/plugins`). For the same plugin, Waywallen uses the
newer version and prefers the user installation when versions match.
