{
  imports = [
    ../base/foot.nix
    ./catppuccin.nix
    ./fonts.nix
  ];

  programs.foot = {
    catppuccin.enable = true;
    settings.main.font = "Iosevka Term Extended:size=14";
  };
}
