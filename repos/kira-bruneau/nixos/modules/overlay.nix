{
  imports = [
    ./hardware/xpadneo.nix
    ./programs/bash/undistract-me.nix
    ./programs/gamemode.nix
    ./services/video/replay-sorcery.nix
  ];

  disabledModules = [
    "hardware/xpadneo.nix"
    "programs/bash/undistract-me.nix"
    "programs/gamemode.nix"
    "services/video/replay-sorcery.nix"
  ];

  nixpkgs.overlays = [ (import ../../overlays).default ];
}
