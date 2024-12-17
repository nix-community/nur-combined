{
  imports = [
    ./hardware/video/intel-gpu-tools.nix
    ./hardware/xpadneo.nix
    ./programs/bash/undistract-me.nix
    ./programs/gamemode.nix
    ./services/bluetooth-autoconnect.nix
    ./services/habitica.nix
  ];

  disabledModules = [
    "hardware/video/intel-gpu-tools.nix"
    "hardware/xpadneo.nix"
    "programs/bash/undistract-me.nix"
    "programs/gamemode.nix"
    "services/bluetooth-autoconnect.nix"
    "services/habitica.nix"
  ];

  nixpkgs.overlays = [ (import ../../overlays).default ];
}
