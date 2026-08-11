{lib, ...}: {
  home.activation.konsaveConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    konsave_src="$HOME/Configs/konsave"
    konsave_dst="$HOME/.config/konsave"

    if [ ! -d "$konsave_src" ]; then
      echo "Konsave configuration directory not found: $konsave_src" >&2
      exit 1
    fi

    if [ -e "$konsave_dst" ] && [ ! -L "$konsave_dst" ]; then
      echo "Refusing to replace non-symlink Konsave configuration: $konsave_dst" >&2
      exit 1
    fi

    mkdir -p "$HOME/.config"
    ln -sfn "$konsave_src" "$konsave_dst"
  '';
}
