{lib, ...}: {
  home.activation.kittyConfig = lib.mkAfter ''
    mkdir -p "$HOME/.config"
    rm -rf "$HOME/.config/kitty"
    ln -sfn "$HOME/Configs/kitty" "$HOME/.config/kitty"
  '';
}
