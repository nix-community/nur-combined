{ allInputs, config, lib, mkCommon, vacuRoot, ... }:
let
  hosts = {
    compute-deck = {
      inp = [
        "jovian"
        "home-manager"
        "disko"
        "padtype"
      ];
      unstable = true;
      # jovian puts in overlays via module
      readOnlyPkgs = false;
    };
    liam.inp = [ "sops-nix" ];
    shel-installer-iso = {
      module = /${vacuRoot}/hosts/installer/iso.nix;
      readOnlyPkgs = false;
    };
    shel-installer-pxe = {
      module = /${vacuRoot}/hosts/installer/pxe.nix;
      readOnlyPkgs = false;
    };
    fw.inp = [
      "nixos-hardware"
      "sops-nix"
      "tf2-nix"
    ];
    mmm = {
      inp = [ "nixos-apple-silicon" ];
      system = "aarch64-linux";
      unstable = true;
      readOnlyPkgs = false;
    };
    prophecy.inp = [
      "impermanence"
      "sops-nix"
      "disko"
      "declarative-jellyfin"
    ];
    solis.inp = [
      "disko"
      "impermanence"
      "sops-nix"
    ];
  };

  topLevelOf =
    hostName:
    let
      thisHostConfig = config.flake.nixosConfigurations.${hostName}.config;
    in
    thisHostConfig.system.build.toplevel // { config = thisHostConfig; };
in
{
  config.flake.nixosConfigurations = builtins.mapAttrs (name:
    {
      unstable ? false,
      module ? /${vacuRoot}/hosts/${name},
      system ? "x86_64-linux",
      inp ? [ ],
      readOnlyPkgs ? true,
    }:
    let
      whichPkgs = if unstable then allInputs.nixpkgs-unstable else allInputs.nixpkgs;
      common = mkCommon {
        inherit unstable inp system;
        vacuModuleType = "nixos";
      };
    in
    whichPkgs.lib.nixosSystem {
      inherit (common) specialArgs;
      modules = [
        { nixpkgs.pkgs = common.pkgs; }
        /${vacuRoot}/common
        module
      ] ++ lib.optional readOnlyPkgs allInputs.nixpkgs.nixosModules.readOnlyPkgs;
    }
  ) hosts;

  config.flake.qb = lib.mkMerge [
    (builtins.mapAttrs (
      name:
      _:
      topLevelOf name
    ) hosts)
    rec {
      cd = topLevelOf "compute-deck";
      prop = topLevelOf "prophecy";
      iso = config.flake.nixosConfigurations.shel-installer-iso.config.system.build.isoImage;
      pxe-build = config.flake.nixosConfigurations.shel-installer-pxe.config.system.build;
      pxe-toplevel = pxe-build;
      pxe-kernel = pxe-build.kernel;
      pxe-initrd = pxe-build.netbootRamdisk;
    }
  ];
}
