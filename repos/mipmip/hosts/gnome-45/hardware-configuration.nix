{ config, lib, pkgs, modulesPath, ... }:

{
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize =  4096;
      cores = 3;
    };
  };

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
