# trampoline from flake.nix into the specific host definition, while doing a tiny bit of common setup

# args from flake-level `import`
{ hostName, localSystem }:

# module args
{ config, lib, ... }:

{
  imports = [
    ./by-name/${hostName}
    ./common
    ./modules
  ];

  networking.hostName = hostName;
  nixpkgs.buildPlatform = lib.mkIf (localSystem != null) localSystem;
  sane.cross.enablePatches = localSystem != null;

  # nixpkgs.overlays = [
  #   (next: prev: {
  #     # for local != target we by default just emulate the target while building.
  #     # provide a `pkgs.cross.<pkg>` alias that consumers can use instead of `pkgs.<foo>`
  #     # to explicitly opt into non-emulated cross compilation for any specific package.
  #     # this is most beneficial for large packages with few pre-requisites -- like Linux.
  #     cross = prev.crossFrom."${localSystem}";
  #   })
  # ];
}
