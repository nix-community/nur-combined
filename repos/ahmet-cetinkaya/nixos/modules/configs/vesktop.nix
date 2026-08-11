{
  lib,
  pkgs,
  ...
}: {
  home.activation.vencordConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    base="$HOME/.var/app/dev.vencord.Vesktop/config/vesktop"
    src="$HOME/Configs/vesktop"

    for src_path in "$src/settings" "$src/themes" "$src/settings.json"; do
      if [ ! -e "$src_path" ]; then
        echo "Vesktop configuration source not found: $src_path" >&2
        exit 1
      fi
    done

    mkdir -p "$HOME/.var/app/dev.vencord.Vesktop/config"

    # Flatpak expects a real config directory; only symlink selected entries.
    if [ -L "$base" ]; then
      rm -f "$base"
    fi
    mkdir -p "$base"

    for target in settings themes settings.json; do
      dst="$base/$target"
      if [ -e "$dst" ] && [ ! -L "$dst" ]; then
        echo "Refusing to replace non-symlink Vesktop configuration: $dst" >&2
        exit 1
      fi
    done

    ln -sfn "$src/settings" "$base/settings"
    ln -sfn "$src/themes" "$base/themes"
    ln -sfn "$src/settings.json" "$base/settings.json"

    # Allow Vesktop Flatpak to read symlink targets in ~/Configs/vesktop.
    if ! ${pkgs.flatpak}/bin/flatpak override --user --filesystem="$src" dev.vencord.Vesktop; then
      echo "Warning: failed to grant Vesktop Flatpak access to $src" >&2
    fi
  '';
}
