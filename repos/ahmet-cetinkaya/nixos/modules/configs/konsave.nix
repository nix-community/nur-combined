{lib, ...}: {
  home.activation.konsaveConfig = lib.mkAfter ''
    mkdir -p "$HOME/.config"
    rm -rf "$HOME/.config/konsave"
    mkdir -p "$HOME/Configs/konsave"
    chmod -R u+rwX "$HOME/Configs/konsave" || true
    ln -sfn "$HOME/Configs/konsave" "$HOME/.config/konsave"
  '';
}
