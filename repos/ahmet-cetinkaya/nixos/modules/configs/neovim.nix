{lib, ...}: {
  home.activation.neovimConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    nvim_src="$HOME/Configs/neovim"
    nvim_dst="$HOME/.config/nvim"

    if [ ! -d "$nvim_src" ]; then
      echo "Neovim configuration directory not found: $nvim_src" >&2
      exit 1
    fi

    if [ -e "$nvim_dst" ] && [ ! -L "$nvim_dst" ]; then
      echo "Refusing to replace non-symlink Neovim configuration: $nvim_dst" >&2
      exit 1
    fi

    mkdir -p "$HOME/.config"
    ln -sfn "$nvim_src" "$nvim_dst"
  '';
}
