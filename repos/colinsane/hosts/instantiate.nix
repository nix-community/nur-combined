# trampoline from flake.nix into the specific host definition, while doing a tiny bit of common setup

# args from flake-level `import`
{ hostName, localSystem }:

# module args
{ lib, ... }:

{
  imports = [
    ./by-name/${hostName}
    ./common
    ./modules
  ];

  networking.hostName = hostName;
  nixpkgs.buildPlatform = lib.mkIf (localSystem != null) localSystem;
}
