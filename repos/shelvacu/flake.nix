{
  description = "Configs for shelvacu's nix things";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nixpkgs-lib.url = "github:nix-community/nixpkgs.lib";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";

    # keep-sorted start block=yes
    colin = {
      url = "git+https://git.uninsane.org/colin/nix-files";
      flake = false;
    };
    declarative-jellyfin = {
      url = "github:shelvacu-forks/declarative-jellyfin/y-u-root";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    depotdownloader-src = {
      url = "git+https://git.uninsane.org/shelvacu/depotdownloader.git?ref=vacu-fork";
      flake = false;
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
    dnspython-src = {
      url = "github:shelvacu-forks/dnspython";
      flake = false;
    };
    flake-compat.url = "github:edolstra/flake-compat";
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs-lib";
    };
    flake-utils.url = "github:numtide/flake-utils";
    gradle2nix = {
      url = "github:tadfisher/gradle2nix/v2";
      flake = false;
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
    mio-nurpkgs.url = "github:mio-19/nurpkgs";
    most-winningest = {
      url = "github:captain-jean-luc/most-winningest";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    nix-on-droid = {
      # url = "github:nix-community/nix-on-droid";
      url = "github:shelvacu-forks/nix-on-droid/stable-ish";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    nixos-apple-silicon-unstable = {
      url = "github:nix-community/nixos-apple-silicon";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    nixos-hardware = {
      url = "github:nixos/nixos-hardware";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim = {
      url = "github:nix-community/nixvim/nixos-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-unstable = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    padtype-unstable = {
      url = "git+https://git.uninsane.org/shelvacu/padtype.git";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    pynixos = {
      url = "git+https://git.uninsane.org/shelvacu/pynixos.git";
      inputs.nixpkgs.follows = "nixpkgs";
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
    # keep-sorted end
  };

  nixConfig = {
    extra-substituters = [ "https://nixcache.shelvacu.com" ];
    extra-trusted-public-keys = [
      "nixcache.shelvacu.com:73u5ZGBpPRoVZfgNJQKYYBt9K9Io/jPwgUfuOLsJbsM="
    ];
  };

  outputs =
    allInputs:
    let
      inherit (allInputs.nixpkgs-lib) lib;
      flake-parts-lib = allInputs.flake-parts.lib;
      vacuRoot = ./.;
      vaculib = import ./vaculib { inherit lib; };
      vacuCommonArgsPre = {
        inherit vaculib vacuRoot;
        vacuSelf = allInputs.self;
      };
      dnsEval =
        let
          inner = lib.evalModules {
            modules = [
              /${vacuRoot}/common
              /${vacuRoot}/dns
            ];
            specialArgs = vacuCommonArgsPre // {
              inherit (allInputs) dns;
              inherit vacuModules;
              vacuModuleType = "dns";
            };
          };
        in
        inner.config.vacu.withAsserts inner;
      vacuCommonArgs = vacuCommonArgsPre // {
        inherit dnsEval;
      };
      commonArgs = vacuCommonArgs // {
        inherit lib;
      };
      plainOverlays = import ./overlays commonArgs;
      flakeOverlays = map (name: allInputs.${name}.overlays.default) [
        "sm64baserom"
        "most-winningest"
        "pynixos"
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
          new: _old:
          lib.attrsets.unionOfDisjoint (mkVacuCommonPkgArgs { pkgs = new; }) {
            inherit (allInputs) depotdownloader-src dnspython-src;
            hasVacuFlakeOverlay = true;
            inherit (allInputs.mio-nurpkgs.packages.${new.stdenv.hostPlatform.system})
              betterbird
              betterbird-unwrapped
              ;
            vacu-keys-src = "${allInputs.vacu-keys}";
            gradle2nix = import allInputs.gradle2nix { pkgs = new; };
            vacuPlainEval = mkPlain (mkCommon {
              pkgs = new;
              vacuModuleType = "plain";
            });
          }
        )
        ++ plainOverlays
        ++ flakeOverlays;
      vacuModules = import ./modules commonArgs;
      defaultSuffixedInputNames = [
        "nixvim"
        "nixpkgs"
        "vacu-keys"
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
            android_sdk.accept_license = true;
            permittedInsecurePackages = [
              # the security warning might as well have said "its insecure maybe but there's nothing you can do about it"
              # presumably needed by nheko
              "olm-3.2.16"
              "fluffychat-linux-1.27.0"
              "qtwebengine-5.15.19"

              # TODO: replace with sth else
              "opendkim-2.11.0-Beta2"
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
          pkgs ? null,
          vacuModuleType,
        }@args:
        let
          pkgsStable = mkPkgs {
            unstable = false;
            inherit system;
          };
          pkgsUnstable = mkPkgs {
            unstable = true;
            inherit system;
          };
          argsPkgs = args.pkgs or null;
          pkgs =
            if argsPkgs != null then
              argsPkgs
            else if unstable then
              pkgsUnstable
            else
              pkgsStable;
          inputs = mkInputs { inherit unstable inp; };
          vacuCommonPkgArgs =
            (mkVacuCommonPkgArgs { inherit pkgs; })
            // {
              inherit inputs;
            }
            // lib.optionalAttrs (argsPkgs == null) { inherit pkgsStable pkgsUnstable; };
        in
        rec {
          inherit pkgs;
          specialArgs = {
            inherit vacuModules vacuModuleType;
            # vacuModuleKind = throw "You used vacuModuleKind, you want vacuModuleType";
            vacuSpecialArgs = specialArgs;
            inherit (allInputs) dns;
          }
          // vacuCommonPkgArgs;
        }
        // vacuCommonPkgArgs;
      mkPlain =
        common:
        let
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
      flakePartsEval =
        allInputs.flake-parts.lib.evalFlakeModule
          {
            inputs = allInputs;
            specialArgs = {
              inherit
                allInputs
                mkCommon
                lib
                vaculib
                vacuRoot
                ;
            };
          }
          {
            systems = [
              "x86_64-linux"
              "aarch64-linux"
            ];
            imports = [
              ./flake
              (flake-parts-lib.mkTransposedPerSystemModule {
                name = "vacuPerSystem";
                option = lib.mkOption {
                  type = lib.types.attrsOf lib.types.raw;
                  default = { };
                };
                file = ./flake.nix;
              })
              {
                options.flake = vaculib.mkOutOptions { inherit lib vaculib dnsEval; };
                # options.flake.lib = vaculib.mkOutOption lib;
                # options.flake.vaculib = vaculib.mkOutOption vaculib;
                # options.flake.vaculib = vaculib.mkOutOption vaculib;
                config.perSystem =
                  { system, ... }:
                  let
                    common = mkCommon {
                      inherit system;
                      vacuModuleType = "plain";
                    };
                    plainEval = mkPlain common;
                    args = {
                      inherit plainEval common;
                      inherit (common) pkgs vacupkglib;
                    };
                  in
                  {
                    vacuPerSystem = args // {
                      inherit system;
                    };
                    _module.args = args;
                  };
              }
            ];
          };
    in
    lib.attrsets.unionOfDisjoint flakePartsEval.config.flake { inherit flakePartsEval; };
}
