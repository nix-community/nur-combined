inputs:
let
  lib = inputs.nixpkgs.lib;
  mkOpts =
    system: module:
    inputs.unf.lib.json {
      inherit (inputs) self;
      pkgs = inputs.nixpkgs.legacyPackages.${system};
      modules = [ module ];
    };

  nixpkgsCfg = {
    overlays = [
      inputs.nix-topology.overlays.default
      inputs.nur.overlays.default
      inputs.nix-vscode-extensions.overlays.default
      inputs.fenix.overlays.default
      inputs.copyparty.overlays.default
      (_final: prev: {
        flashrom = prev.flashrom.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [
            (prev.writeText "flashrom-fix-dangling-chip-pointer.patch" ''
              diff --git a/tests/chip.c b/tests/chip.c
              --- a/tests/chip.c
              +++ b/tests/chip.c
              @@ -778,7 +778,8 @@ static void setup_bad_chip(struct flashrom_flashctx *flashctx)
               	g_test_write_injector = NULL;
               	g_test_read_injector = NULL;
               	g_test_erase_injector[0] = NULL;

              -	struct flashchip mock_chip = chip_bad;
              +	static struct flashchip mock_chip;
              +	mock_chip = chip_bad;
               	const char *param = ""; /* Default values for all params. */

               	setup_chip(flashctx, &mock_chip, param, NULL);
            '')
          ];
        });
      })
      # Apply local packages last so every host (and Home Manager) uses this repo's versions.
      inputs.self.overlays.default
    ];
    config = {
      allowUnfree = true;
      allowUnfreePredicate = _: true;
    };
  };

  # Let hosts configure avy's dotfile modules without nesting under home-manager.users.avy.
  homeDotsModule =
    { config, ... }:
    {
      options.dots = lib.mkOption {
        type = lib.types.attrsOf lib.types.anything;
        default = { };
        description = "Host-level settings forwarded to avy's Home Manager dots options";
      };
      config = lib.mkIf (config.dots != { }) {
        home-manager.users.avy.dots = config.dots;
      };
    };

  homeManagerCfg =
    {
      userPackages ? true,
      pkgs,
      extraImports ? [ ],
    }:
    {
      home-manager.useGlobalPkgs = true;
      home-manager.extraSpecialArgs = {
        inherit inputs;
        inherit mkOpts;
      };
      home-manager.users.avy.imports = [
        inputs.sops-nix.homeManagerModules.sops
        ./modules/secrets/home.nix
        inputs.nix-index-database.homeModules.nix-index
        inputs.catppuccin.homeModules.catppuccin
        inputs.try.homeModules.default
        (inputs.import-tree.filterNot (
          path:
          lib.hasSuffix "/avy/default.nix" path
          || lib.hasSuffix "/avy/packages.nix" path
          || lib.hasInfix "/avy/dotfiles/" path
        ) ./users)
      ]
      ++ (
        if pkgs.stdenv.hostPlatform.isDarwin then
          [
            inputs.mac-app-util.homeManagerModules.default
          ]
        else
          [ ]
      )
      ++ extraImports;
      home-manager.backupFileExtension = "bak";
      home-manager.useUserPackages = userPackages;
    };
in
{
  inherit nixpkgsCfg homeManagerCfg;

  mkDarwin = machineHostname: _nixpkgsVersion: system: extraHmModules: extraModules: {
    darwinConfigurations.${machineHostname} = inputs.darwin.lib.darwinSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        ./machines/darwin
        ./machines/darwin/${machineHostname}
        inputs.sops-nix.darwinModules.sops
        ./modules/secrets
        inputs.mac-app-util.darwinModules.default
        inputs.home-manager.darwinModules.home-manager
        homeDotsModule
        inputs.nix-index-database.darwinModules.nix-index
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.niks3.darwinModules.niks3-auto-upload
        {
          home-manager.users.avy.home.homeDirectory = lib.mkForce "/Users/avy";
          nix-homebrew = {
            enable = true;
            enableRosetta = false;
            user = "avy";
            taps = {
              "homebrew/homebrew-core" = inputs.nixpkgs.legacyPackages.${system}.fetchFromGitHub {
                owner = "homebrew";
                repo = "homebrew-core";
                rev = inputs.homebrew-core.rev;
                hash = inputs.homebrew-core.narHash;
                name = "homebrew-core-tap";
              };
              "homebrew/homebrew-cask" = inputs.homebrew-cask;
              "TheBoredTeam/homebrew-boring-notch" = inputs.brew-boring-notch;
              "Sikarugir-App/homebrew-sikarugir" = inputs.brew-sikarugir;
              "fenio/homebrew-tap" = inputs.brew-anylinuxfs-gui;
              "nohajc/homebrew-anylinuxfs" = inputs.brew-anylinuxfs;
              "slp/homebrew-krun" = inputs.brew-krun;
            };
            mutableTaps = false;
            autoMigrate = true;
          };
        }
        (homeManagerCfg {
          userPackages = true;
          pkgs = inputs.nixpkgs.legacyPackages.${system};
          extraImports = extraHmModules;
        })
      ]
      ++ extraModules;
    };
  };

  mkNixos = machineHostname: nixpkgsVersion: hardware: _extraHmModules: extraModules: {
    nixosConfigurations.${machineHostname} = nixpkgsVersion.lib.nixosSystem {
      system = hardware;
      specialArgs = { inherit inputs; };
      modules = [
        ./homelab
        ./machines/nixos
        ./machines/nixos/${machineHostname}
        ./modules/email
        ./modules/ddns
        ./modules/heTunnel
        ./modules/secrets
        inputs.nix-mineral.nixosModules.nix-mineral
        inputs.sops-nix.nixosModules.sops
        inputs.nix-topology.nixosModules.default
        inputs.nix-index-database.nixosModules.nix-index
        inputs.home-manager.nixosModules.home-manager
        homeDotsModule
        inputs.catppuccin.nixosModules.catppuccin
        inputs.srvos.nixosModules.mixins-terminfo
        inputs.niks3.nixosModules.niks3-auto-upload
        inputs.disko.nixosModules.disko
      ]
      ++ extraModules;
    };
  };

  mkMerge = lib.lists.foldl' (a: b: lib.attrsets.recursiveUpdate a b) { };

}
