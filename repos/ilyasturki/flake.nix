{
  description = "Emulators missing from nixpkgs, and newer builds of the ones that lag behind";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    # No `follows`: the cache only holds builds against eden-nix's own pin, and
    # their CI is what validates the recipe. Rebuilding Eden against a different
    # nixpkgs throws both away.
    eden-nix.url = "github:Daaboulex/eden-nix";
  };

  outputs =
    {
      self,
      nixpkgs,
      eden-nix,
    }:
    let
      systems = [ "x86_64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # nx-optimizer ships under CC-BY-NC, which nixpkgs treats as unfree.
      # Consumers of `overlays.default` need `allowUnfree` for that one attribute.
      pkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "nx-optimizer";
          overlays = [ self.overlays.default ];
        }
      );
    in
    {
      overlays.default =
        final: _prev:
        import ./default.nix { pkgs = final; }
        // {
          eden = eden-nix.packages.${final.stdenv.hostPlatform.system}.eden;
        };

      packages = forAllSystems (system: {
        inherit (pkgsFor.${system})
          atmosphere
          citron-neo
          hekate
          nx-optimizer
          panda3ds
          pcsx2
          ryujinx-canary
          ;
        eden = eden-nix.packages.${system}.eden;
      });

      nixosModules.default = {
        imports = [
          eden-nix.nixosModules.default
          ./modules/default.nix
        ];
        nixpkgs.overlays = [ self.overlays.default ];
      };

      # `nix flake check` only confirms nixosModules.default *is* a module, never
      # that it evaluates, so a broken option here reaches consumers green.
      checks = forAllSystems (
        system:
        self.packages.${system}
        // {
          nixos-module =
            (nixpkgs.lib.nixosSystem {
              inherit system;
              modules = [
                self.nixosModules.default
                {
                  boot.loader.grub.devices = [ "/dev/sda" ];
                  fileSystems."/" = {
                    device = "/dev/sda1";
                    fsType = "ext4";
                  };
                  system.stateVersion = "26.05";
                  programs.citron-neo.enable = true;
                  programs.panda3ds.enable = true;
                  programs.pcsx2.enable = true;
                  programs.ryujinx-canary.enable = true;
                }
              ];
            }).config.system.build.toplevel;
        }
      );

      devShells = forAllSystems (system: {
        default = pkgsFor.${system}.mkShellNoCC {
          packages = with pkgsFor.${system}; [
            actionlint
            curl
            git
            jq
            nix-prefetch-git
            perl
            shellcheck
          ];
        };
      });

      formatter = forAllSystems (system: pkgsFor.${system}.nixfmt-tree);
    };
}
