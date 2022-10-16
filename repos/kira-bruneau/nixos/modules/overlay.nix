{
  imports = [
    ./hardware/xpadneo.nix
    ./programs/bash/undistract-me.nix
    ./programs/gamemode.nix
    ./services/video/replay-sorcery.nix
    ./services/x11/display-managers/lightdm-greeters/webkit2.nix
  ];

  disabledModules = [
    "hardware/xpadneo.nix"
    "programs/bash/undistract-me.nix"
    "programs/gamemode.nix"
    "services/video/replay-sorcery.nix"
  ];

  nixpkgs.overlays = [ (import ../../overlays).default ];
}
