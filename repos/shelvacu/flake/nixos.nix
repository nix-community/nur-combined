{
  allInputs,
  config,
  lib,
  mkCommon,
  vacuRoot,
  ...
}:
let
  hosts = {
    # keep-sorted start block=yes
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
    fw.inp = [
      "nixos-hardware"
      "sops-nix"
      "tf2-nix"
    ];
    liam.inp = [ "sops-nix" ];
    prophecy.inp = [
      "impermanence"
      "sops-nix"
      "disko"
      "declarative-jellyfin"
      "nix-minecraft"
    ];
    quasar2.inp = [ "sops-nix" ];
    ripper = { };
    shel-installer-iso = {
      module = /${vacuRoot}/hosts/installer/iso.nix;
      readOnlyPkgs = false;
    };
    savm = { };
    shel-installer-pxe = {
      module = /${vacuRoot}/hosts/installer/pxe.nix;
      readOnlyPkgs = false;
    };
    solis.inp = [
      "disko"
      "impermanence"
      "sops-nix"
    ];
    vacu-agent-vm = { };
    # keep-sorted end
  };

  topLevelOf =
    hostName:
    let
      thisHostConfig = config.flake.nixosConfigurations.${hostName}.config;
    in
    thisHostConfig.system.build.toplevel // { config = thisHostConfig; };
in
{
  config.flake.nixosConfigurations = builtins.mapAttrs (
    name:
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
      ]
      ++ lib.optional readOnlyPkgs allInputs.nixpkgs.nixosModules.readOnlyPkgs;
    }
  ) hosts;

  config.vacuBuilds = lib.mkMerge [
    (builtins.mapAttrs (
      name:
      {
        system ? "x86_64-linux",
        ...
      }:
      {
        primarySystem = system;
        multiSystem = false;
        derivations.${system} = topLevelOf name;
      }
    ) hosts)
    {
      compute-deck.aliases = [ "cd" ];
      prophecy.aliases = [ "prop" ];
      shel-installer-pxe.aliases = [
        "pxe"
        "pxe-build"
        "pxe-toplevel"
      ];
      vacu-agent-vm.aliases = [
        "agent-vm"
        "agent"
      ];

      iso = {
        primarySystem = "x86_64-linux";
        multiSystem = false;
        derivations.x86_64-linux =
          let
            isoConfig = config.flake.nixosConfigurations.shel-installer-iso.config;
          in
          isoConfig.system.build.isoImage // { config = isoConfig; };
      };
    }
  ];
}
