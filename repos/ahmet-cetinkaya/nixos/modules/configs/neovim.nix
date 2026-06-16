{lib, ...}: {
  home.activation.neovimConfig = lib.mkAfter ''
    mkdir -p "$HOME/.config"
    rm -rf "$HOME/.config/nvim"
    ln -sfn "$HOME/Configs/neovim" "$HOME/.config/nvim"
  '';
}
