{
  description = "avy's (avycado13) nix configuration";

  inputs = {
    nixpkgs.url = "https://channels.nixos.org/nixos-unstable/nixexprs.tar.zst";
    darwin = {
      url = "github:lnl7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    mac-app-util.url = "github:hraban/mac-app-util";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-mineral.url = "github:cynicsketch/nix-mineral";
    nix-topology.url = "github:oddlama/nix-topology";
    nix-search-tv.url = "github:3timeslazy/nix-search-tv";
    brew-boring-notch = {
      url = "github:TheBoredTeam/homebrew-boring-notch";
      flake = false;
    };
    brew-sikarugir = {
      url = "github:Sikarugir-App/homebrew-sikarugir";
      flake = false;
    };
    catppuccin.url = "github:catppuccin/nix";
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    flake-utils.url = "github:numtide/flake-utils";
    llm-agents.url = "github:numtide/llm-agents.nix";
    nix-auth.url = "github:numtide/nix-auth";
    terminal-wakatime = {
      url = "github:hackclub/terminal-wakatime";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wakatime-ls.url = "github:mrnossiom/wakatime-ls";
    wakatime-ls.inputs.nixpkgs.follows = "nixpkgs";
    nix-minecraft.url = "github:Infinidoge/nix-minecraft";
    srvos.url = "github:nix-community/srvos";
    unf = {
      url = "git+https://git.atagen.co/atagen/unf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs.nixpkgs.follows = "";
      inputs.home-manager.follows = "";
    };
    try.url = "github:tobi/try";
    fenix = {
      url = "github:nix-community/fenix/monthly";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    brew-anylinuxfs-gui = {
      url = "github:fenio/homebrew-tap";
      flake = false;
    };
    brew-anylinuxfs = {
      url = "github:nohajc/homebrew-anylinuxfs";
      flake = false;
    };
    brew-krun = {
      url = "github:slp/homebrew-krun";
      flake = false;
    };
    niks3.url = "github:Mic92/niks3";
    lard.url = "github:taciturnaxolotl/lard";
    nix-cache-beacon.url = "github:adisbladis/nix-cache-beacon";
    devour-flake = {
      url = "github:srid/devour-flake";
      flake = false;
    };
    copyparty.url = "github:9001/copyparty";
    nixos-pi-zero-2 = {
      url = "github:plmercereau/nixos-pi-zero-2";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    import-tree.url = "github:denful/import-tree";
  };

  outputs =
    inputs:
    let
      helpers = import ./flakeHelpers.nix inputs;
      inherit (helpers)
        mkMerge
        mkDarwin
        mkNixos
        homeManagerCfg
        ;
      system = {
        x86_64-linux = "x86_64-linux";
        aarch64-linux = "aarch64-linux";
        aarch64-darwin = "aarch64-darwin";
      };
    in
    mkMerge [
      (mkDarwin "Avys-Mac" inputs.nixpkgs system.aarch64-darwin [ ] [ ])

      (mkNixos "pi0" inputs.nixpkgs system.aarch64-linux
        [ ]
        [
          inputs.nixos-pi-zero-2.nixosModules.hardware
          inputs.nixos-pi-zero-2.nixosModules.sd-image
        ]
      )

      (mkNixos "pi1" inputs.nixpkgs system.aarch64-linux [ ] [ ])
      (mkNixos "pi2" inputs.nixpkgs system.aarch64-linux
        [ ]
        [ "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix" ]
      )

      (mkNixos "apollo1" inputs.nixpkgs "aarch64-linux"
        [ ]
        [
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
        ]
      )

      (mkNixos "apollo13" inputs.nixpkgs "aarch64-linux"
        [ ]
        [
          "${inputs.nixpkgs}/nixos/modules/installer/sd-card/sd-image.nix"
        ]
      )

      (mkNixos "oracle" inputs.nixpkgs system.x86_64-linux
        [ ]
        [
          inputs.srvos.nixosModules.server
          "${inputs.nixpkgs}/nixos/modules/virtualisation/oci-image.nix"
        ]
      )
      (mkNixos "eclipse" inputs.nixpkgs system.x86_64-linux
        [ ]
        [
          inputs.srvos.nixosModules.server
        ]
      )
      (mkNixos "0xff" inputs.nixpkgs system.x86_64-linux
        [ ]
        [
          inputs.srvos.nixosModules.server
          (homeManagerCfg {
            userPackages = true;
            pkgs = inputs.nixpkgs.legacyPackages.${system.x86_64-linux};
          })
        ]
      )
      (mkNixos "gce" inputs.nixpkgs system.x86_64-linux [ ] [ ])
      (mkNixos "nest" inputs.nixpkgs system.x86_64-linux [ ] [ ])
      (mkNixos "iso" inputs.nixpkgs system.x86_64-linux [ ] [ ])
      {
        overlays.default =
          final: prev:
          (import ./overlay.nix final prev)
          // {
            devour-flake = prev.callPackage inputs.devour-flake { };
          };
      }

      (inputs.flake-utils.lib.eachSystem (builtins.attrValues system) (
        system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [ inputs.self.overlays.default ];
          };
          nurPackages = import ./default.nix { inherit pkgs; };
          treefmtEval = inputs.treefmt-nix.lib.evalModule pkgs {
            projectRootFile = "flake.nix";
            programs.nixfmt.enable = true;
            programs.deadnix.enable = true;
            programs.shellcheck.enable = true;
          };
        in
        {
          legacyPackages = nurPackages;
          packages = inputs.nixpkgs.lib.filterAttrs (
            _: package:
            inputs.nixpkgs.lib.isDerivation package
            && inputs.nixpkgs.lib.meta.availableOn pkgs.stdenv.hostPlatform package
          ) nurPackages;
          formatter = treefmtEval.config.build.wrapper;
          checks.formatting = treefmtEval.config.build.check inputs.self;
          devShells.default = pkgs.mkShell {
            packages = [
              pkgs.just
              pkgs.nh
              pkgs.nixos-rebuild-ng
              treefmtEval.config.build.wrapper
              pkgs.sops
              pkgs.ssh-to-age
              pkgs.nil
              pkgs.cachix
              pkgs.nix-output-monitor
              inputs.niks3.packages.${system}.niks3
              pkgs.devour-flake
              pkgs.omnix
              (pkgs.writeShellApplication {
                name = "nix-build-all";
                runtimeInputs = [
                  pkgs.nix
                  pkgs.devour-flake
                ];
                text = ''
                  # Make sure that flake.lock is sync
                  nix flake lock --no-update-lock-file

                  # Do a full nix build (all outputs)
                  # This uses https://github.com/srid/devour-flake
                  devour-flake . "$@"
                '';
              })
            ];
          };
        }
      ))
      {
        nixConfig = {
          extra-substituters = [ "https://cache.avyay.in/c/default/main" ];
          extra-trusted-public-keys = [ "main:dQ6VTlBqbChv4jdFSjf2g9pmylkXFkQEaFXLHuzWfMM=" ];
        };

      }
    ];
}
