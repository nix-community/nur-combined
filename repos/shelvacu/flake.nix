{
  description = "Configs for shelvacu's nix things";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable-small";

    colin = {
      url = "git+https://git.uninsane.org/colin/nix-files";
      flake = false;
    };

    declarative-jellyfin = {
      url = "github:shelvacu-forks/declarative-jellyfin/y-u-root";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko = {
      url = "git+https://git.uninsane.org/shelvacu/disko.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    disko-unstable = {
      url = "git+https://git.uninsane.org/shelvacu/disko.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    dns = {
      url = "github:nix-community/dns.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    impermanence.url = "github:nix-community/impermanence";
    jovian-unstable = {
      # there is no stable jovian :cry:
      url = "github:Jovian-Experiments/Jovian-NixOS";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    mio-nurpkgs = {
      url = "github:mio-19/nurpkgs";
      # it *is* a flake, but I'm not using it as one
      flake = false;
    };
    most-winningest = {
      url = "github:captain-jean-luc/most-winningest";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nixos-hardware.url = "github:nixos/nixos-hardware";
    nixos-apple-silicon-unstable = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-unstable = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nix-on-droid = {
      url = "github:nix-community/nix-on-droid";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    padtype-unstable = {
      url = "git+https://git.uninsane.org/shelvacu/padtype.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    sm64baserom.url = "git+https://git.uninsane.org/shelvacu/sm64baserom.git";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tf2-nix = {
      url = "gitlab:shelvacu-forks/tf2-nix/with-my-patches";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    vacu-keys = {
      url = "git+https://git.uninsane.org/shelvacu/keys.nix.git";
      flake = false;
    };
  };

  outputs = allInputs:
  let
    inherit (allInputs.nixpkgs-lib) lib;
    vacuRoot = ./.;
    vaculib = import ./vaculib {
      inherit lib;
    };
    vacuCommonArgs = {
      inherit vaculib vacuRoot;
    };
    commonArgs = vacuCommonArgs // { inherit lib; };
    plainOverlays = import ./overlays commonArgs;
    flakeOverlays = map (name: allInputs.${name}.overlays.default) [
      "sm64baserom"
      "most-winningest"
    ];
    mkVacuCommonPkgArgs =
      { pkgs }:
      let
        vacupkglib = import ./vacupkglib ({ inherit pkgs lib; } // vacuCommonPkgArgs);
        vacuCommonPkgArgs = vacuCommonArgs // {
          inherit vacupkglib;
        };
      in
      vacuCommonPkgArgs;
    overlays =
      [ ]
      ++ lib.singleton (
        new: _old: lib.attrsets.unionOfDisjoint (mkVacuCommonPkgArgs { pkgs = new; }) {
          betterbird-unwrapped = new.callPackage "${allInputs.mio-nurpkgs}/pkgs/betterbird" { };
          betterbird = new.wrapThunderbird new.betterbird-unwrapped {
            applicationName = "betterbird";
            libName = "betterbird";
          };
        }
      )
      ++ plainOverlays
      ++ flakeOverlays
      ;
    vacuModules = import ./modules commonArgs;
    defaultSuffixedInputNames = [
      "nixvim"
      "nixpkgs"
    ];
    defaultInputs = { inherit (allInputs) self vacu-keys; };
    mkInputs =
      {
        unstable ? false,
        inp ? [ ],
      }:
      let
        suffix = if unstable then "-unstable" else "";
        inputNames = inp ++ defaultSuffixedInputNames;
        thisInputsA = vaculib.mapNamesToAttrs (name: allInputs.${name + suffix}) inputNames;
      in
      if inp == "all" then allInputs else thisInputsA // defaultInputs;
    mkPkgs =
      arg:
      let
        argAttrAll = if builtins.isString arg then { system = arg; } else arg;
        unstable = argAttrAll.unstable or false;
        whichpkgs = if unstable then allInputs.nixpkgs-unstable else allInputs.nixpkgs;
        argAttr = lib.removeAttrs argAttrAll [ "unstable" ];
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            # the security warning might as well have said "its insecure maybe but there's nothing you can do about it"
            # presumably needed by nheko
            "olm-3.2.16"
            "fluffychat-linux-1.27.0"
          ];
        }
        // (argAttr.config or { });
      in
      import whichpkgs (
        argAttr // { inherit config; } // { overlays = (argAttr.overlays or [ ]) ++ overlays; }
      );
    mkCommon =
      {
        unstable ? false,
        inp ? [ ],
        system ? "x86_64-linux",
        vacuModuleType,
      }:
      let
        pkgsStable = mkPkgs {
          unstable = false;
          inherit system;
        };
        pkgsUnstable = mkPkgs {
          unstable = true;
          inherit system;
        };
        pkgs = if unstable then pkgsUnstable else pkgsStable;
        inputs = mkInputs { inherit unstable inp; };
        vacuCommonPkgArgs = mkVacuCommonPkgArgs { inherit pkgs; };
      in
      {
        inherit
          pkgs
          pkgsStable
          pkgsUnstable
          inputs
          ;
        specialArgs = {
          inherit
            inputs
            vacuModules
            vacuModuleType
            pkgsStable
            pkgsUnstable
            ;
          inherit (allInputs) dns;
        } // vacuCommonPkgArgs;
      } // vacuCommonPkgArgs;
    mkPlain =
      {
        unstable ? false,
        system,
      }@args:
      let
        common = mkCommon (
          args
          // {
            vacuModuleType = "plain";
            inp = "all";
          }
        );
        inner = lib.evalModules {
          modules = [
            /${vacuRoot}/common
            { vacu.systemKind = "server"; }
          ];
          specialArgs = common.specialArgs // {
            inherit (common) pkgs;
            inherit (common.pkgs) lib;
          };
        };
      in
      inner.config.vacu.withAsserts inner;
  in
    allInputs.flake-parts.lib.mkFlake {
      inputs = allInputs;
      specialArgs = {
        inherit allInputs mkCommon lib vaculib vacuRoot;
      };
    } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      imports = [
        ./flake
        {
          perSystem = { system, ... }:
          let
            common = mkCommon { inherit system; vacuModuleType = "plain"; };
            plainConfig = mkPlain { inherit system; };
          in
          {
            _module.args = {
              inherit plainConfig;
              inherit (common) pkgs vacupkglib;
            };
          };
        }
      ];
    };
}
