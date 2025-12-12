{ allInputs, config, lib, mkCommon, vacuRoot, ... }:
let
  hosts = {
    triple-dezert.inp = [
      "most-winningest"
      "sops-nix"
    ];
    # compute-deck = {
    #   inp = [
    #     "jovian"
    #     "home-manager"
    #     "disko"
    #     "padtype"
    #   ];
    #   unstable = true;
    # };
    liam.inp = [ "sops-nix" ];
    lp0 = { };
    # shel-installer-iso = { module = /${vacuRoot}/hosts/installer/iso.nix; };
    # shel-installer-pxe = { module = /${vacuRoot}/hosts/installer/pxe.nix; };
    fw.inp = [
      "nixos-hardware"
      "sops-nix"
      "tf2-nix"
    ];
    legtop.inp = [ "nixos-hardware" ];
    # mmm = {
    #   inp = [ "nixos-apple-silicon" ];
    #   system = "aarch64-linux";
    #   unstable = true;
    # };
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
    config.flake.nixosConfigurations.${hostName}.config.system.build.toplevel;
in
{
  config.flake.nixosConfigurations = builtins.mapAttrs (name:
    {
      unstable ? false,
      module ? /${vacuRoot}/hosts/${name},
      system ? "x86_64-linux",
      inp ? [ ],
    }:
    let
      common = mkCommon {
        inherit unstable inp system;
        vacuModuleType = "nixos";
      };
    in
    allInputs.nixpkgs.lib.nixosSystem {
      inherit (common) specialArgs;
      modules = [
        allInputs.nixpkgs.nixosModules.readOnlyPkgs
        {
          nixpkgs.pkgs = common.pkgs;
        }
        /${vacuRoot}/common
        module
      ];
    }
  ) hosts;

  config.flake.qb = lib.mkMerge [
    (builtins.mapAttrs (
      name:
      _:
      topLevelOf name
    ) hosts)
    rec {
      # cd = topLevelOf "compute-deck";
      prop = topLevelOf "prophecy";
      # iso = config.flake.nixosConfigurations.shel-installer-iso.config.system.build.isoImage;
      # pxe-build = config.flake.nixosConfigurations.shel-installer-pxe.config.system.build;
      # pxe-toplevel = pxe-build;
      # pxe-kernel = pxe-build.kernel;
      # pxe-initrd = pxe-build.netbootRamdisk;
    }
  ];
}
