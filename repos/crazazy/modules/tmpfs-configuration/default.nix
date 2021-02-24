{ pkgs, config, lib, ... }:
with lib;
{
  imports = [
    ./home-config.nix
    ./system-config.nix
  ];
  options.tmpfs-setup.enable = mkOption {
    type = types.bool;
    default = false;
    description = ''
      this option will enable an impermanence implementation
      if enabled. don't touch otherwise
    '';
  };
}
