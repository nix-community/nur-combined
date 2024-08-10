{
  imports = [
    ./hardware/video/intel-gpu-tools.nix
    ./hardware/xpadneo.nix
    ./programs/bash/undistract-me.nix
    ./programs/gamemode.nix
  ];

  disabledModules = [
    "hardware/video/intel-gpu-tools.nix"
    "hardware/xpadneo.nix"
    "programs/bash/undistract-me.nix"
    "programs/gamemode.nix"
  ];

  nixpkgs.overlays = [ (import ../../overlays).default ];
}
