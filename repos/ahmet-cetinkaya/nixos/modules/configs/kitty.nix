{lib, ...}: {
  home.activation.kittyConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    kitty_src="$HOME/Configs/kitty"
    kitty_dst="$HOME/.config/kitty"

    if [ ! -d "$kitty_src" ]; then
      echo "Kitty configuration directory not found: $kitty_src" >&2
      exit 1
    fi

    if [ -e "$kitty_dst" ] && [ ! -L "$kitty_dst" ]; then
      echo "Refusing to replace non-symlink Kitty configuration: $kitty_dst" >&2
      exit 1
    fi

    mkdir -p "$HOME/.config"
    ln -sfn "$kitty_src" "$kitty_dst"
  '';
}
