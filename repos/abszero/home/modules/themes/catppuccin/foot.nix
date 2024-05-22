{
  imports = [
    ../base/foot.nix
    ./catppuccin.nix
    ./fonts.nix
  ];

  programs.foot.settings.main.font = "Iosevka Term Extended:size=14";
}
