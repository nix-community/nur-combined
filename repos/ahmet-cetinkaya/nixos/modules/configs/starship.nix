{lib, ...}: {
  home.activation.starshipConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    starship_src="$HOME/Configs/starship/starship.toml"
    starship_dst="$HOME/.config/starship.toml"

    if [ ! -f "$starship_src" ]; then
      echo "Starship configuration file not found: $starship_src" >&2
      exit 1
    fi

    if [ -e "$starship_dst" ] && [ ! -L "$starship_dst" ]; then
      echo "Refusing to replace non-symlink Starship configuration: $starship_dst" >&2
      exit 1
    fi

    mkdir -p "$HOME/.config"
    ln -sfn "$starship_src" "$starship_dst"
  '';
}
