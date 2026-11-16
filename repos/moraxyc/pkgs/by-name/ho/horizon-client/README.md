# Horizon

```sh
nix build .#horizon-client .#horizon-prepare

nix run .#horizon-prepare -- --prepare --complete \
  --server-jar /path/to/server.jar \
  --minecraft-dir "$HOME/.minecraft" \
  --output "$HOME/.local/share/horizon/resources"

nix run .#horizon-client -- \
  --resources "$HOME/.local/share/horizon/resources"
```

Use the Minecraft version and JAR revision pinned by this build's
`research-lock.json`, not an arbitrary server JAR. The installed Minecraft
version must have been played once so its libraries and assets are available.
`horizon-prepare --launch-api` reports the pinned Minecraft and Java versions.

The preparer includes JDK 25 and copies its working files to
`${XDG_DATA_HOME:-$HOME/.local/share}/horizon-nix/prepare`. Set
`HORIZON_PREPARE_ROOT` or pass `--root` to choose a different working directory.

Sources track upstream's main branch, pinned in `_sources/lock.json`. Update
with `nix develop -c update-packages horizon`.
