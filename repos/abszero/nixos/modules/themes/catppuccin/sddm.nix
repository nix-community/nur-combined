{
  imports = [
    ./catppuccin.nix
    ./fonts.nix
  ];

  services.displayManager.sddm.catppuccin = {
    enable = true;
    font = "Open Sans";
    fontSize = "13";
  };
}
