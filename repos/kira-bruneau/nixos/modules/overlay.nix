{
  imports = [
    ./hardware/xpadneo.nix
    ./programs/bash/undistract-me.nix
    ./programs/gamemode.nix
  ];

  disabledModules = [
    "hardware/xpadneo.nix"
    "programs/bash/undistract-me.nix"
    "programs/gamemode.nix"
  ];

  nixpkgs.overlays = [ (import ../../overlays).default ];
}
