{lib, ...}: {
  home.activation.vscodiumFiles = lib.mkAfter ''
    vs_dir="$HOME/Configs/vs-codium"
    mkdir -p "$HOME/.config/VSCodium"
    mkdir -p "$HOME/.config/Code/User"

    rm -rf "$HOME/.config/VSCodium/product.json" "$HOME/.config/Code/User/settings.json"
    ln -sfn "$vs_dir/product.json" "$HOME/.config/VSCodium/product.json"
    ln -sfn "$vs_dir/settings.json" "$HOME/.config/Code/User/settings.json"
  '';

  home.activation.vscodiumKeybindings = lib.mkAfter ''
    vs_dir="$HOME/Configs/vs-codium"
    profiles_dir="$HOME/.config/Code/User/profiles"
    mkdir -p "$profiles_dir"

    for profile in "$profiles_dir"/*; do
      if [ -d "$profile" ]; then
        rm -rf "$profile/keybindings.json"
        ln -sfn "$vs_dir/keybindings.json" "$profile/keybindings.json"
      fi
    done
  '';
}
