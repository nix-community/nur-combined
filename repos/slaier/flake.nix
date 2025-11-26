{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nur.url = "github:nix-community/NUR";
    nur.inputs.nixpkgs.follows = "nixpkgs";

    darkmatter-grub-theme.url = "gitlab:VandalByte/darkmatter-grub-theme";
    darkmatter-grub-theme.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs-unstable";

    niri = {
      url = "github:sodiboo/niri-flake";
    };

    bluetooth-player = {
      url = "github:slaier/bluetooth-player";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, ... } @inputs:
    let
      system = "x86_64-linux";
      hostname = "local";

      lib = nixpkgs.lib;
      mylib = import ./lib { inherit lib; };
      overlayList = mylib.recursiveValuesToList overlays;
      pkgs = import nixpkgs { inherit system; overlays = overlayList; };

      nixosModules = mylib.fromDirectoryRecursive {
        directory = ./modules;
        filename = "default.nix";
        transformer = lib.id;
      };
      homeModules = mylib.fromDirectoryRecursive {
        directory = ./modules;
        filename = "home.nix";
        transformer = lib.id;
      };
      packages = mylib.fromDirectoryRecursive {
        directory = ./modules;
        filename = "package.nix";
        transformer = pkg: pkgs.callPackage pkg { };
      };
      overlays = mylib.fromDirectoryRecursive {
        directory = ./modules;
        filename = "overlay.nix";
        transformer = import;
      };
    in
    {
      packages.${system} = (mylib.flattenAttrset packages) // {
        nixos-installer = pkgs.writeShellScriptBin "nixos-installer" ''
          exec nixos-install --flake "${self}#${hostname}" "$@"
        '';
      };
      formatter.${system} = pkgs.nixpkgs-fmt;
      inherit overlays;
      inherit nixosModules;
      nixosConfigurations.${hostname} = lib.nixosSystem {
        modules = with inputs; [
          darkmatter-grub-theme.nixosModule
          home-manager.nixosModules.home-manager
          niri.nixosModules.niri
          nix-index-database.nixosModules.nix-index
          nur.modules.nixos.default
          sops-nix.nixosModules.sops
          ({ config, lib, ... }: {
            _module.args = {
              inherit inputs;
            };
            imports = (mylib.recursiveValuesToList nixosModules) ++ [
              ./hosts/local
            ];

            nixpkgs.overlays = overlayList ++ [
              bluetooth-player.overlays."${config.nixpkgs.hostPlatform.system}".default
              niri.overlays.niri
              nix-vscode-extensions.overlays.default
              (final: _prev: {
                niriswitcher = final.callPackage "${inputs.nixpkgs-unstable}/pkgs/by-name/ni/niriswitcher/package.nix" { };
              })
            ];

            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [
                sops-nix.homeManagerModules.sops
                nix-index-database.homeModules.nix-index
              ];
              users.nixos.imports = mylib.recursiveValuesToList homeModules;
            };

            networking.hostName = lib.mkDefault hostname;
          })
        ];
      };
      nixosConfigurations."ins" = self.nixosConfigurations.${hostname}.extendModules {
        modules = [
          {
            environment.systemPackages = [
              self.packages.${system}.nixos-fs-init
              self.packages.${system}.nixos-fs-mount
              self.packages.${system}.nixos-installer
            ];
            networking.hostName = "ins";
          }
        ];
      };
      nixosConfigurations."ins-iso" = lib.nixosSystem {
        inherit system;
        modules = [
          ({ pkgs, modulesPath, ... }: {
            imports = [ (modulesPath + "/installer/cd-dvd/installation-cd-minimal.nix") ];
            isoImage.squashfsCompression = "gzip -Xcompression-level 1";
            environment.systemPackages = with pkgs; [
              git
              self.packages.${system}.nixos-fs-init
              self.packages.${system}.nixos-fs-mount
              self.packages.${system}.nixos-installer
            ];
            environment.etc."install-closure".source =
              let
                closureInfo = pkgs.closureInfo {
                  rootPaths = [
                    self.nixosConfigurations.${hostname}.config.system.build.toplevel
                  ];
                };
              in
              "${closureInfo}/store-paths";
            nix.settings = {
              auto-allocate-uids = true;
              auto-optimise-store = true;
              experimental-features = "auto-allocate-uids cgroups nix-command flakes";
              substituters = [
                "https://mirrors.ustc.edu.cn/nix-channels/store"
                "https://slaier.cachix.org"
                "https://nix-community.cachix.org"
              ];
              trusted-public-keys = [
                "slaier.cachix.org-1:NyXPOqlxuGWgyn0ApNHMopkbix3QjMUAcR+JOjjxLtU="
                "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
              ];
              use-cgroups = true;
            };
          })
        ];
      };
      devShells.${system}.default = with pkgs; mkShell {
        packages = [
          just
          nixos-rebuild
          sops
        ];
      };
    };
}
