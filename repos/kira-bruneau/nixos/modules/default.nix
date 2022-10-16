{
  gamemode = ./programs/gamemode.nix;
  lightdm-webkit2-greeter = ./services/x11/display-managers/lightdm-greeters/webkit2.nix;
  overlay = ./overlay.nix;
  replay-sorcery = ./services/video/replay-sorcery.nix;
  undistract-me = ./programs/bash/undistract-me.nix;
  xpadneo = ./hardware/xpadneo.nix;
}
