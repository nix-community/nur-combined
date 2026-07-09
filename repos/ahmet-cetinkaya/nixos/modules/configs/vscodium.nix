{lib, ...}: {
  # product.json's "nameShort"/"nameLong" override makes VSCodium report
  # itself as "Code", so it reads its user data from ~/.config/Code instead
  # of the default ~/.config/VSCodium. The official VS Code build always
  # reads from ~/.config/Code natively. Both editors therefore end up
  # sharing the same settings/keybindings — the symlinks below only need to
  # target ~/.config/Code once to cover both.
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
    user_dir="$HOME/.config/Code/User"
    profiles_dir="$user_dir/profiles"
    mkdir -p "$profiles_dir"

    # Default (root) profile — used until the user creates additional
    # profiles in either editor.
    rm -rf "$user_dir/keybindings.json"
    ln -sfn "$vs_dir/keybindings.json" "$user_dir/keybindings.json"

    for profile in "$profiles_dir"/*; do
      if [ -d "$profile" ]; then
        rm -rf "$profile/keybindings.json"
        ln -sfn "$vs_dir/keybindings.json" "$profile/keybindings.json"
      fi
    done
  '';
}
