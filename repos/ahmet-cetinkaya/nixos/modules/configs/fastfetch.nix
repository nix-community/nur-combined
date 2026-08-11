{lib, ...}: {
  home.activation.fastfetchConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    ff_dir="$HOME/Configs/fastfetch"

    for ff_file in config.jsonc mini-config.jsonc; do
      if [ ! -f "$ff_dir/$ff_file" ]; then
        echo "Fastfetch configuration file not found: $ff_dir/$ff_file" >&2
        exit 1
      fi
    done

    mkdir -p "$HOME/.config/fastfetch"

    for ff_file in config.jsonc mini-config.jsonc; do
      ff_dst="$HOME/.config/fastfetch/$ff_file"
      if [ -e "$ff_dst" ] && [ ! -L "$ff_dst" ]; then
        echo "Refusing to replace non-symlink Fastfetch configuration: $ff_dst" >&2
        exit 1
      fi
    done

    ln -sfn "$ff_dir/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    ln -sfn "$ff_dir/mini-config.jsonc" "$HOME/.config/fastfetch/mini-config.jsonc"
  '';
}
