{lib, ...}: {
  home.activation.starshipConfig = lib.mkAfter ''
    mkdir -p "$HOME/.config"
    rm -rf "$HOME/.config/starship.toml"
    ln -sfn "$HOME/Configs/starship/starship.toml" "$HOME/.config/starship.toml"
  '';
}
