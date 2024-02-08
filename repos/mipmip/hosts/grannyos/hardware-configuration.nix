{ config, lib, pkgs, modulesPath, ... }:

{

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  virtualisation.vmVariant = {
    virtualisation = {
      memorySize =  4096;
      cores = 3;
    };
  };
}
