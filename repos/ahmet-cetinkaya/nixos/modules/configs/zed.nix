{lib, ...}: {
  home.activation.zedConfig = lib.mkAfter ''
    mkdir -p "$HOME/.config"
    rm -rf "$HOME/.config/zed"
    mkdir -p "$HOME/.config/zed"
    ln -sfn "$HOME/Configs/zed/settings.json" "$HOME/.config/zed/settings.json"
    ln -sfn "$HOME/Configs/zed/keymap.json" "$HOME/.config/zed/keymap.json"
    ln -sfn "$HOME/Configs/zed/debug.json" "$HOME/.config/zed/debug.json"
  '';
}
