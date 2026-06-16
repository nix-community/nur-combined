{
  lib,
  pkgs,
  ...
}: {
  home.activation.vencordConfig = lib.mkAfter ''
    base="$HOME/.var/app/dev.vencord.Vesktop/config/vesktop"
    src="$HOME/Configs/vesktop"

    mkdir -p "$HOME/.var/app/dev.vencord.Vesktop/config"

    # Flatpak expects a real config directory; only symlink selected entries.
    if [ -L "$base" ]; then
      rm -f "$base"
    fi
    mkdir -p "$base"

    rm -rf "$base/settings" "$base/themes" "$base/settings.json"
    ln -sfn "$src/settings" "$base/settings"
    ln -sfn "$src/themes" "$base/themes"
    ln -sfn "$src/settings.json" "$base/settings.json"

    # Allow Vesktop Flatpak to read symlink targets in ~/Configs/vesktop.
    ${pkgs.flatpak}/bin/flatpak override --user --filesystem="$src" dev.vencord.Vesktop || true
  '';
}
