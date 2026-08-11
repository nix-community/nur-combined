{lib, ...}: {
  # Link the entire Zed config directory instead of individual files.
  # Per-file links break because Zed writes settings atomically via temp file +
  # rename, and the previous hook `rm -rf`'d the whole directory, wiping
  # runtime-generated content (e.g. themes/) and forcing resets.
  # A single directory symlink survives Zed's atomic writes and avoids data loss.
  home.activation.zedConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    zed_src="$HOME/Configs/zed"
    zed_dst="$HOME/.config/zed"

    if [ ! -d "$zed_src" ]; then
      echo "Zed configuration directory not found: $zed_src" >&2
      exit 1
    fi

    if [ -e "$zed_dst" ] && [ ! -L "$zed_dst" ]; then
      echo "Refusing to replace non-symlink Zed configuration: $zed_dst" >&2
      exit 1
    fi

    mkdir -p "$HOME/.config"
    ln -sfn "$zed_src" "$zed_dst"
  '';
}
