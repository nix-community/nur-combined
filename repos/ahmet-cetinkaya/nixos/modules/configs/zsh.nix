{lib, ...}: {
  home.activation.zshConfig = lib.mkAfter ''
    rm -rf "$HOME/.zshrc"
    ln -sfn "$HOME/Configs/zsh/nixos.zshrc" "$HOME/.zshrc"
  '';
}
