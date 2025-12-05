{
  description = "Configs for shelvacu's nix things";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.05-small";
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable-small";

    colin = {
      url = "git+https://git.uninsane.org/colin/nix-files";
      flake = false;
    };

    copyparty.url = "github:9001/copyparty";
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
    flake-utils.url = "github:numtide/flake-utils";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
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
      url = "github:nix-community/nixvim/nixos-25.05";
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

  outputs =
    {
      self,
      nixpkgs,
      nix-on-droid,
      ...
    }@allInputs:
    let
      x86 = "x86_64-linux";
      arm = "aarch64-linux";
      lib = import "${nixpkgs}/lib";
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
        "copyparty"
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
            betterbird-unwrapped = pkgs.callPackage "${allInputs.mio-nurpkgs}/pkgs/betterbird" { };
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
          system ? x86,
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
          system ? x86,
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
              ./common
              { vacu.systemKind = "server"; }
            ];
            specialArgs = common.specialArgs // {
              inherit (common) pkgs;
              inherit (common.pkgs) lib;
            };
          };
        in
        inner.config.vacu.withAsserts inner;
      pkgs = mkPkgs x86;
      mkNixosConfig =
        {
          unstable ? false,
          module,
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
            ./common
            module
          ];
        };
    in
    {
      debug = {
        isoDeriv = import "${allInputs.nixpkgs}/nixos/release-small.nix" {
          nixpkgs = ({ revCount = 0; } // allInputs.nixpkgs);
        };
        inherit lib vaculib;
      };

      nixosConfigurations = {
        triple-dezert = mkNixosConfig {
          module = ./hosts/triple-dezert;
          inp = [
            "most-winningest"
            "sops-nix"
          ];
        };
        compute-deck = mkNixosConfig {
          module = ./hosts/compute-deck;
          inp = [
            "jovian"
            "home-manager"
            "disko"
            "padtype"
          ];
          unstable = true;
        };
        liam = mkNixosConfig {
          module = ./hosts/liam;
          inp = [ "sops-nix" ];
        };
        lp0 = mkNixosConfig { module = ./hosts/lp0; };
        shel-installer-iso = mkNixosConfig { module = ./hosts/installer/iso.nix; };
        shel-installer-pxe = mkNixosConfig { module = ./hosts/installer/pxe.nix; };
        fw = mkNixosConfig {
          module = ./hosts/fw;
          inp = [
            "nixos-hardware"
            "sops-nix"
            "tf2-nix"
          ];
        };
        legtop = mkNixosConfig {
          module = ./hosts/legtop;
          inp = [ "nixos-hardware" ];
        };
        mmm = mkNixosConfig {
          module = ./hosts/mmm;
          inp = [ "nixos-apple-silicon" ];
          system = "aarch64-linux";
          unstable = true;
        };
        prophecy = mkNixosConfig {
          module = ./hosts/prophecy;
          system = "x86_64-linux";
          inp = [
            "impermanence"
            "sops-nix"
            "disko"
            "declarative-jellyfin"
          ];
        };
        solis = mkNixosConfig {
          module = ./hosts/solis;
          system = "x86_64-linux";
          inp = [
            "disko"
            "impermanence"
            "sops-nix"
          ];
        };
      };

      nixOnDroidConfigurations.default =
        let
          common = mkCommon {
            system = arm;
            vacuModuleType = "nix-on-droid";
          };
        in
        nix-on-droid.lib.nixOnDroidConfiguration {
          modules = [
            ./common
            ./hosts/nix-on-droid
          ];
          extraSpecialArgs = common.specialArgs;
          inherit (common) pkgs;
        };

      checks = nixpkgs.lib.genAttrs [ x86 ] (
        system:
        let
          common = mkCommon {
            inherit system;
            vacuModuleType = "nixos";
          };
          inherit (common) pkgs;
          plain = mkPlain { inherit system; };
          commonTestModule = {
            hostPkgs = pkgs;
            _module.args = common.specialArgs;
            node.pkgs = pkgs;
            node.pkgsReadOnly = true;
            node.specialArgs = lib.removeAttrs common.specialArgs [ "inputs" ];
          };
          mkTest =
            { name, isExistingHost ? true }:
            nixpkgs.lib.nixos.runTest {
              imports = [
                commonTestModule
                ./tests/${name}
                {
                  node.specialArgs.inputs =
                    if isExistingHost
                    then self.nixosConfigurations.${name}._module.specialArgs.inputs
                    else common.specialArgs.inputs;
                }
              ];
            };
          checksFromConfig = plain.config.vacu.checks;
        in
        lib.attrsets.unionOfDisjoint
          checksFromConfig
          {
            liam = mkTest { name = "liam"; };
            triple-dezert = mkTest { name = "triple-dezert"; };
            caddy-kanidm = mkTest { name = "caddy-kanidm"; isExistingHost = false; };
          }
      );

      buildList =
        let
          toplevelOf = name: self.nixosConfigurations.${name}.config.system.build.toplevel;
          deterministicCerts = import ./deterministic-certs.nix { nixpkgs = mkPkgs x86; };
          renamedAarchPackages = lib.mapAttrs' (
            name: value: lib.nameValuePair (name + "-aarch64") value
          ) self.packages.aarch64-linux;
          packages = lib.attrsets.unionOfDisjoint self.packages.x86_64-linux renamedAarchPackages;
          pxe-build = self.nixosConfigurations.shel-installer-pxe.config.system.build;
        in
        lib.attrsets.unionOfDisjoint
          packages
          {
            fw = toplevelOf "fw";
            triple-dezert = toplevelOf "triple-dezert";
            compute-deck = toplevelOf "compute-deck";
            liam = toplevelOf "liam";
            lp0 = toplevelOf "lp0";
            legtop = toplevelOf "legtop";
            mmm = toplevelOf "mmm";
            shel-installer-iso = toplevelOf "shel-installer-iso";
            shel-installer-pxe = toplevelOf "shel-installer-pxe";
            prophecy = toplevelOf "prophecy";
            iso = self.nixosConfigurations.shel-installer-iso.config.system.build.isoImage;
            pxe-toplevel = toplevelOf "shel-installer-pxe";
            pxe-kernel = pxe-build.kernel;
            pxe-initrd = pxe-build.netbootRamdisk;
            check-triple-dezert = self.checks.x86_64-linux.triple-dezert.driver;
            check-liam = self.checks.x86_64-linux.liam.driver;
            check-caddy-kanidm = self.checks.x86_64-linux.caddy-kanidm.driver;
            liam-sieve = self.nixosConfigurations.liam.config.vacu.liam-sieve-script;

            nix-on-droid = self.nixOnDroidConfigurations.default.activationPackage;

            nod-bootstrap-x86_64 = allInputs.nix-on-droid.packages.x86_64-linux.bootstrapZip-x86_64;
            nod-bootstrap-aarch64 = allInputs.nix-on-droid.packages.x86_64-linux.bootstrapZip-aarch64;

            dc-priv = deterministicCerts.privKeyFile "test";
            dc-cert = deterministicCerts.selfSigned "test" { };

            inherit (allInputs.nixos-apple-silicon-unstable.packages.aarch64-linux)
              m1n1
              uboot-asahi
              installer-bootstrap
              ;
            installer-bootstrap-cross =
              allInputs.nixos-apple-silicon-unstable.packages.x86_64-linux.installer-bootstrap;
          };

      qb = lib.attrsets.unionOfDisjoint self.buildList {
        trip = self.buildList.triple-dezert;
        cd = self.buildList.compute-deck;
        lt = self.buildList.legtop;
        prop = self.buildList.prophecy;
        check-trip = self.buildList.check-triple-dezert;
        nod = self.buildList.nix-on-droid;
        ak = self.buildList.authorizedKeys;
        my-sops = self.buildList.wrappedSops;
      };

      brokenBuilds = [
        "sm64coopdx-aarch64"
        "installer-bootstrap"
      ];

      impureBuilds = [
        "nix-on-droid"
        "nod"
        "nod-bootstrap-x86_64"
        "nod-bootstrap-aarch64"
      ];

      archival = import ./archive.nix { inherit self pkgs lib; };
    }
    // (allInputs.flake-utils.lib.eachDefaultSystem (
      system:
      let
        mkNixvim =
          { unstable, minimal }:
          let
            common = mkCommon {
              inherit unstable system;
              vacuModuleType = "nixvim";
            };
            nixvim-input = if unstable then allInputs.nixvim-unstable else allInputs.nixvim;
          in
          nixvim-input.legacyPackages.${system}.makeNixvimWithModule {
            module = {
              imports = [ ./nixvim ];
            };
            extraSpecialArgs = common.specialArgs // {
              inherit minimal;
            };
          };
        common = mkCommon {
          unstable = true;
          inherit system;
          vacuModuleType = "plain";
        };
        inherit (common) pkgs pkgsStable pkgsUnstable;
        plain = mkPlain {
          unstable = true;
          inherit system;
        };
        treefmtEval = allInputs.treefmt-nix.lib.evalModule pkgsUnstable ./treefmt.nix;
        formatter = treefmtEval.config.build.wrapper;
        vacuPackagePaths = import ./packages vacuCommonArgs;
        vacuPackages = builtins.intersectAttrs vacuPackagePaths pkgsStable;
        colinPkgs = import allInputs.colin { localSystem = system; };
      in
      {
        inherit formatter;
        inherit (common) vacupkglib;
        apps.sops = {
          type = "app";
          program = lib.getExe self.packages.${system}.wrappedSops;
        };
        vacuConfig = plain.config;
        legacyPackages = {
          inherit vacuPackages;
          unstable = pkgsUnstable;
          stable = pkgsStable;
          colin = colinPkgs;
          nixpkgs-update =
            { ... }@args:
            import "${allInputs.nixpkgs}/maintainers/scripts/update.nix" (
              { include-overlays = [ (import ./overlays/newPackages.nix) ]; } // args
            );
        };
        packages = rec {
          archive = pkgsStable.callPackage ./scripts/archive { };
          authorizedKeys = pkgsStable.writeText "authorizedKeys" (
            lib.concatStringsSep "\n" (
              lib.mapAttrsToList (k: v: "${v} ${k}") plain.config.vacu.ssh.authorizedKeys
            )
          );
          inherit (pkgsStable) betterbird betterbird-unwrapped;
          dns = import ./scripts/dns {
            inherit pkgs lib;
            inputs = allInputs;
            inherit (plain) config;
            vacuRoot = ./.;
          };
          inherit formatter;
          generated = pkgsStable.linkFarm "generated" {
            nixpkgs = "${allInputs.nixpkgs}";
            "liam-test/hints.py" = pkgsStable.writeText "hints.py" (
              import ./typesForTest.nix {
                name = "liam";
                inherit (pkgsStable) lib;
                inherit self;
                inherit (allInputs) nixpkgs;
              }
            );
            "caddy-kanidm-test/hints.py" = pkgsStable.writeText "hints.py" (
              import ./typesForTest.nix {
                name = "caddy-kanidm";
                inherit (pkgsStable) lib;
                inherit self;
                inherit (allInputs) nixpkgs;
              }
            );
            # "archive/python-env" = builtins.dirOf (builtins.dirOf archive.interpreter);
            "dns/python-env" = builtins.dirOf (builtins.dirOf dns.interpreter);
            "mailtest/python-env" =
              if system == "x86_64-linux" then
                builtins.dirOf (
                  builtins.dirOf self.checks.x86_64-linux.liam.nodes.checker.vacu.mailtest.smtp.interpreter
                )
              else
                pkgsStable.python312.withPackages (
                  p: with p; [
                    imap-tools
                    requests
                  ]
                );
            "general-env" = pkgsStable.python312.withPackages (
              p: with p; [
                scriptipy
                pydantic
                requests
              ]
            );
            # "zfs-supersend/python-env" = builtins.dirOf (builtins.dirOf pkgs.zfs-supersend.interpreter);
          };
          get-crypto-rates = pkgsStable.makeVacuPythonScript "get-crypto-rates" {
            libraries = [
              "pydantic"
              "requests"
            ];
          } ./scripts/get-crypto-rates.py;
          host-pxe-installer = pkgsStable.callPackage ./host-pxe-installer.nix {
            nixosInstaller = self.nixosConfigurations.shel-installer-pxe;
          };
          liam-sieve-script = self.nixosConfigurations.liam.config.vacu.liam-sieve-script;
          nixvim = mkNixvim {
            unstable = false;
            minimal = false;
          };
          nixvim-unstable = mkNixvim {
            unstable = true;
            minimal = false;
          };
          nixvim-minimal = mkNixvim {
            unstable = false;
            minimal = true;
          };
          nixvim-unstable-minimal = mkNixvim {
            unstable = true;
            minimal = true;
          };
          # optionsDocNixOnDroid = (pkgs.nixosOptionsDoc {
          #   inherit (self.nixOnDroidConfigurations.default) options;
          # }).optionsCommonMark;
          openterface-qt-eudev = vacuPackages.openterface-qt.override { useSystemd = false; };
          openterface-qt-systemd = vacuPackages.openterface-qt.override { useSystemd = true; };
          pythonWithStuff = pkgsStable.python313.withPackages (
            p: with p; [
              requests
              scriptipy
              pydantic
            ]
          );
          sopsConfig = plain.config.vacu.sopsConfigFile;
          sourceTree = plain.config.vacu.sourceTree;
          staticSitesTestConfig = pkgsStable.callPackage ./static-sites/test-config.nix { };
          units = plain.config.vacu.units.finalPackage;
          update-git-keys = pkgsStable.callPackage ./scripts/update-git-keys.nix {
            inherit (plain) config;
            inputs = allInputs;
          };
          vnopnCA = pkgsStable.writeText "vnopnCA.cert" plain.config.vacu.vnopnCA;
          wrappedSops = plain.config.vacu.wrappedSops;
        }
        // vacuPackages;
      }
    ));
}
