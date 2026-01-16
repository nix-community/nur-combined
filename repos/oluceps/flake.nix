{
  description = "oluceps' flake";
  outputs =
    inputs@{
      flake-parts,
      vaultix,
      self,
      ...
    }:
    let
      extraLibs = import ./hosts/lib.nix inputs;
      flakeModules = map (n: inputs.${n}.flakeModule);
      defaultOverlays = map (n: inputs.${n}.overlays.default);
    in
    flake-parts.lib.mkFlake { inherit inputs; } (
      { ... }:
      {
        imports =
          (flakeModules [
            "pre-commit-hooks"
            "flake-root"
          ])
          ++ [
            ./hosts
            (import ./topo.nix extraLibs)
            vaultix.flakeModules.default
            inputs.nix-topology.flakeModule
            # inputs.nix-kernelsu-builder.flakeModules.default
            flake-parts.flakeModules.easyOverlay
          ];
        debug = true;
        systems = [
          "x86_64-linux"
          "aarch64-linux"
          "riscv64-linux"
        ];
        perSystem =
          {
            pkgs,
            system,
            config,
            lib,
            ...
          }:
          {
            _module.args.pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = defaultOverlays [
                "fenix"
                "self"
                "nuenv"
              ];
              config = {
                allowUnfreePredicate =
                  pkg:
                  builtins.elem (lib.getName pkg) [
                    "veracrypt"
                    "tetrio-desktop"
                  ];
              };
            };
            overlayAttrs = config.packages;

            pre-commit = {
              check.enable = true;
              settings.hooks = {
                nixfmt = true;
                detect-private-keys.enable = true;
              };
            };

            # flake-root.projectRootFile = ".top";
            devShells.default = pkgs.mkShell {
              shellHook = config.pre-commit.installationScript;
              inputsFrom = [ config.flake-root.devShell ];
              buildInputs = with pkgs; [
                just
                rage
                b3sum
                nushell
                radicle-node
              ];
            };

            packages =
              (lib.packagesFromDirectoryRecursive {
                inherit (pkgs) callPackage;
                directory = ./pkgs/by-name;
              })
              // {
                default = pkgs.symlinkJoin {
                  name = "user-pkgs";
                  paths = import ./userPkgs.nix { inherit pkgs; };
                };
              };
            formatter = pkgs.nixfmt-tree;
            # kernelsu = {
            #   gki-kernelsu-next = {
            #     anyKernelVariant = "kernelsu";
            #     clangVersion = "latest";

            #     kernelSU = {
            #       src = pkgs.fetchFromGitHub {
            #         owner = "tiann";
            #         repo = "KernelSU";
            #         rev = "5f751149bda1729c34379df8b01421ca57a1529b";
            #         hash = "sha256-uuvypweCkERPPW4bLGKfJrZl3zOn7ZiSnmybr/CZdQ8=";
            #       };
            #       variant = "custom";
            #       revision = "32179";
            #       subdirectory = "KernelSU";
            #     };
            #     kernelConfig = ''
            #       CONFIG_LSM="landlock,lockdown,yama,loadpin,safesetid,integrity,selinux,smack,tomoyo,apparmor,bpf,baseband_guard"

            #       CONFIG_BPF_STREAM_PARSER=y
            #       CONFIG_NETFILTER_XT_MATCH_ADDRTYPE=y
            #       CONFIG_NETFILTER_XT_SET=y
            #       CONFIG_IP_SET=y
            #       CONFIG_IP_SET_MAX=65534
            #       CONFIG_IP_SET_BITMAP_IP=y
            #       CONFIG_IP_SET_BITMAP_IPMAC=y
            #       CONFIG_IP_SET_BITMAP_PORT=y
            #       CONFIG_IP_SET_HASH_IP=y
            #       CONFIG_IP_SET_HASH_IPMARK=y
            #       CONFIG_IP_SET_HASH_IPPORT=y
            #       CONFIG_IP_SET_HASH_IPPORTIP=y
            #       CONFIG_IP_SET_HASH_IPPORTNET=y
            #       CONFIG_IP_SET_HASH_IPMAC=y
            #       CONFIG_IP_SET_HASH_MAC=y
            #       CONFIG_IP_SET_HASH_NETPORTNET=y
            #       CONFIG_IP_SET_HASH_NET=y
            #       CONFIG_IP_SET_HASH_NETNET=y
            #       CONFIG_IP_SET_HASH_NETPORT=y
            #       CONFIG_IP_SET_HASH_NETIFACE=y
            #       CONFIG_IP_SET_LIST_SET=y
            #       CONFIG_IP6_NF_NAT=y
            #       CONFIG_IP6_NF_TARGET_MASQUERADE=y

            #       CONFIG_TCP_CONG_ADVANCED=y
            #       CONFIG_TCP_CONG_BBR=y
            #       CONFIG_NET_SCH_FQ=y
            #       CONFIG_TCP_CONG_BIC=n
            #       CONFIG_TCP_CONG_WESTWOOD=n
            #       CONFIG_TCP_CONG_HTCP=n
            #       CONFIG_DEFAULT_BBR=y
            #       CONFIG_TCP_WINDOW_SCALING=y

            #       # Add additional tmpfs config setting
            #       CONFIG_TMPFS_XATTR=y
            #       CONFIG_TMPFS_POSIX_ACL=y

            #       # Add additional config setting
            #       CONFIG_IP_NF_TARGET_TTL=y
            #       CONFIG_IP6_NF_TARGET_HL=y
            #       CONFIG_IP6_NF_MATCH_HL=y
            #     '';
            #     bbg.enable = true;
            #     susfs =
            #       let
            #         src = pkgs.fetchFromGitHub {
            #           owner = "ShirkNeko";
            #           repo = "susfs4ksu";
            #           rev = "a442dda6e77c56d74d86b9009951d813642c0673";
            #           hash = "sha256-zuzyjprh1OGsXQF9FI31BEEoParUoE9GFB6dcwxbad0=";
            #         };
            #       in
            #       {
            #         enable = false;
            #         kernelPatch = null;
            #         inherit src;
            #       };

            #     kernelDefconfigs = [
            #       "gki_defconfig"
            #     ];
            #     kernelImageName = "Image";
            #     kernelMakeFlags = [
            #       "KCFLAGS=\"-w\""
            #       "KCPPFLAGS=\"-w\""
            #       "EXTRAVERSION=-android14-11-sukisu+susfs+bbg"
            #       # "V=1"
            #     ];
            #     # kernelPatches = [
            #     #   "${
            #     #     pkgs.fetchFromGitHub {
            #     #       owner = "WildPlusKernel";
            #     #       repo = "kernel_patches";
            #     #       rev = "2cbe9ad4797a468415f94d3e5fa8648333030971";
            #     #       fetchSubmodules = false;
            #     #       sha256 = "sha256-a+at4quoNttsxx8VtK7qOS4vVJZHSbdMK6hHUearDj8=";
            #     #     }
            #     #   }/69_hide_stuff.patch"
            #     # ];
            #     kernelSrc = lib.cleanSource /home/riro/Src/android-kernel/common;
            #     oemBootImg = ./boot.img;
            #   };
            # };
          };

        flake = {
          vaultix = {
            nodes =
              let
                inherit (inputs.nixpkgs.lib) filterAttrs elem;
              in
              filterAttrs (
                n: _:
                !elem n [
                  # "yidhra"
                  "resq"
                  "livecd"
                  "bootstrap"
                  # "hastur"
                  # "kaambl"
                ]
              ) self.nixosConfigurations;
            identity = self + "/sec/age-yubikey-identity-7d5d5540.txt.pub";
            extraRecipients = [ extraLibs.data.keys.ageKey ];
            defaultSecretDirectory = "./sec";
            cache = "./sec/.cache";
          };
          lib = inputs.nixpkgs.lib.extend self.overlays.lib;

          overlays.lib = final: prev: extraLibs;

          nixosModules =
            let
              shadowedModules = [ ];
              modules =
                let
                  genModule =
                    dir: extraLibs.genFilteredDirAttrsV2 dir shadowedModules (n: import (dir + "/${n}.nix"));
                in
                (genModule ./modules) // { repack = ./repack; };

              default =
                { ... }:
                {
                  imports = builtins.attrValues modules;
                };
            in
            modules // { inherit default; };
        };
      }
    );

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable-small";
    nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-master.url = "github:NixOS/nixpkgs/master";
    nixpkgs-22.url = "github:NixOS/nixpkgs?rev=c91d0713ac476dfb367bbe12a7a048f6162f039c";
    nixpkgs-factorio.url = "github:NixOS/nixpkgs?rev=1b9bd8dd0fd5b8be7fc3435f7446272354624b01";

    nix-topology.url = "github:oddlama/nix-topology";
    niri = {
      url = "github:YaLTeR/niri";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    xwayland-satellite = {
      url = "github:Supreeeme/xwayland-satellite";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-wayland = {
      url = "github:nix-community/nixpkgs-wayland";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    browser-previews = {
      url = "github:nix-community/browser-previews";
    };
    vaultix.url = "github:milieuim/vaultix";
    # vaultix.url = "/home/riro/Src/vaultix";
    nixos-cosmic = {
      url = "github:lilyinstarlight/nixos-cosmic";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lemurs = {
      url = "github:coastalwhite/lemurs";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    ascii2char = {
      url = "github:oluceps/nix-ascii2char";
    };
    # lix = {
    #   url = "git+https://git.lix.systems/lix-project/lix";
    #   flake = false;
    # };
    # lix-module = {
    #   url = "git+https://git.lix.systems/lix-project/nixos-module";
    #   inputs.lix.follows = "lix";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
    radicle = {
      url = "git+https://seed.radicle.xyz/z3gqcJUoA1n9HaHKufZs5FCSGazv5.git";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tg-online-keeper.url = "github:oluceps/TelegramOnlineKeeper";
    # tg-online-keeper.url = "/home/elen/Src/tg-online-keeper";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    catppuccin.url = "github:catppuccin/nix";
    atuin = {
      url = "github:atuinsh/atuin";
    };
    conduit = {
      url = "github:matrix-construct/tuwunel?rev=f2c531429622dcc2f6bf96937e8e1def963cab79";
    };
    factorio-manager = {
      url = "github:asoul-rec/factorio-manager";
      # url = "/home/elen/Src/factorio-manager";
      # inputs.nixpkgs.follows = "nixpkgs";
    };
    anyrun = {
      url = "github:Kirottu/anyrun";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    aagl = {
      url = "github:ezKEa/aagl-gtk-on-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
    };
    # path:/home/riro/Src/flake.nix
    dae.url = "github:oluceps/flake.nix/next";
    # dae.url = "/home/elen/Src/flake.nix";
    nixyDomains.url = "github:oluceps/nixyDomains";
    nixyDomains.flake = false;
    nuenv.url = "github:DeterminateSystems/nuenv";
    nix-direnv.url = "github:nix-community/nix-direnv";
    nix-ld = {
      url = "github:Mic92/nix-ld";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote";
    };
    preservation.url = "github:WilliButz/preservation";
    prismlauncher = {
      url = "github:PrismLauncher/PrismLauncher";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-root.url = "github:srid/flake-root";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-facter-modules.url = "github:numtide/nixos-facter-modules";
    devenv.url = "github:cachix/devenv";
    pgvectors-nixpkgs.url = "github:NixOS/nixpkgs?rev=b468a08276b1e2709168a4d8f04c63360c2140a9";
    microvm = {
      url = "github:microvm-nix/microvm.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    quickshell = {
      url = "github:outfoxxed/quickshell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
      # inputs.quickshell.follows = "quickshell"; # Use same quickshell version
    };
    vicinae = {
      url = "github:vicinaehq/vicinae";
    };
    online-exporter.url = "/home/riro/Src/monitou";
    nix-cachyos-kernel.url = "github:oluceps/nix-cachyos-kernel";
    # nix-kernelsu-builder.url = "/home/riro/Src/nix-kernelsu-builder";
    # "github:xddxdd/nix-kernelsu-builder";
    self.submodules = true;

  };
}
