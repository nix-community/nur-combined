{lib, ...}: {
  home.activation.zshConfig = lib.hm.dag.entryAfter ["writeBoundary"] ''
    zsh_src="$HOME/Configs/zsh/nixos.zshrc"
    zsh_dst="$HOME/.zshrc"

    if [ ! -f "$zsh_src" ]; then
      echo "Zsh configuration file not found: $zsh_src" >&2
      exit 1
    fi

    if [ -e "$zsh_dst" ] && [ ! -L "$zsh_dst" ]; then
      echo "Refusing to replace non-symlink Zsh configuration: $zsh_dst" >&2
      exit 1
    fi

    ln -sfn "$zsh_src" "$zsh_dst"
  '';
}
