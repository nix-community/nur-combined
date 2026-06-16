{lib, ...}: {
  home.activation.fastfetchConfig = lib.mkAfter ''
    ff_dir="$HOME/Configs/fastfetch"
    mkdir -p "$HOME/.config/fastfetch"

    rm -rf "$HOME/.config/fastfetch/config.jsonc" "$HOME/.config/fastfetch/mini-config.jsonc"
    ln -sfn "$ff_dir/config.jsonc" "$HOME/.config/fastfetch/config.jsonc"
    ln -sfn "$ff_dir/mini-config.jsonc" "$HOME/.config/fastfetch/mini-config.jsonc"
  '';
}
