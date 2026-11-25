# Sunrise

```sh
nix build .#sunrise-client .#sunrise-prepare

nix run .#sunrise-prepare -- --prepare --complete \
  --server-jar /path/to/server.jar \
  --minecraft-dir "$HOME/.minecraft" \
  --output "$HOME/.local/share/sunrise/resources"

nix run .#sunrise-client -- \
  --resources "$HOME/.local/share/sunrise/resources"
```

Use the Minecraft version and JAR revision pinned by this build's
`research-lock.json`, not an arbitrary server JAR. The installed Minecraft
version must have been played once so its libraries and assets are available.
`sunrise-prepare --launch-api` reports the pinned Minecraft and Java versions.

The preparer includes JDK 25 and copies its working files to
`${XDG_DATA_HOME:-$HOME/.local/share}/sunrise-nix/prepare`. Set
`SUNRISE_PREPARE_ROOT` or pass `--root` to choose a different working directory.

Sources track upstream's main branch, pinned in `_sources/lock.json`. Update
with `nix develop -c update-packages sunrise`.
