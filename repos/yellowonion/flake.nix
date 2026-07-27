{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bcachefs-tools = {
      url = "github:YellowOnion/bcachefs-tools";
    };
    utils.url = "github:numtide/flake-utils";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
  };

  };
  outputs = { self, nixpkgs, bcachefs-tools, utils, flake-compat }:
    utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        lib = pkgs.lib;

        dotToUnderscore = pkgs.lib.strings.stringAsChars (x: if x == "." then "_" else x);
        kernelVersion = lib.versions.majorMinor (lib.readFile ./VERSION);
        rebaseBroken  = (lib.readFile ./REBASE_BROKEN) == "yes\n";

        baseKernel = pkgs.linuxKernel.kernels."linux_${dotToUnderscore kernelVersion}";

        mkKernel = broken: name: debug: extraPatches : (pkgs.callPackage ./pkgs/bcachefs-kernel {
          inherit broken rebaseBroken debug;
          kernel = baseKernel;
          variant = name ;
          kernelPatches = [
            pkgs.kernelPatches.bridge_stp_helper
            pkgs.kernelPatches.request_key_helper
          ] ++ extraPatches;
          useLocalPatch = false;
        });
        bcachefs-kernel = mkKernel false "master" true [];
        packages = {
          inherit bcachefs-kernel;
          bcachefs-tools = bcachefs-tools.packages.${system}.default;
        };
        overlay = super: final: packages;
      in
      {
        inherit packages;

        nixosConfigurations = {
          bcachefs-iso = (nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              ({...}: {
                nixpkgs.overlays = [ overlay ];
              })
              ./iso.nix
            ];
          }).config.system.build.isoImage.overrideAttrs (self: self // { perferLocalBuilds = true ;});
        };
      });
}
