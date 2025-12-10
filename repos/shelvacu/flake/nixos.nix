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
      config.nixosConfigurations.${name}.config.system.build.toplevel
    ) hosts)
    {
      cd = config.qb.compute-deck;
      prop = config.qb.prophecy;
      iso = config.nixosConfigurations.shel-installer-iso.config.system.build.isoImage;
      pxe-build = config.nixosConfigurations.shel-installer-pxe.config.system.build;
      pxe-toplevel = config.qb.pxe-build;
      pxe-kernel = config.qb.pxe-build.kernel;
      pxe-initrd = config.qb.pxe-build.netbootRamdisk;
    }
  ];
}
