{
  description = "nixcfg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsLatest.url = "github:NixOS/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR/master";
    nix-ld.url = "github:Mic92/nix-ld";
    pocket2kindle = {
      url = "github:lucasew/pocket2kindle";
      flake = false;
    };
    nixgram = {
      url = "github:lucasew/nixgram/master";
      flake = false;
    };
    dotenv = {
      url = "github:lucasew/dotenv";
      flake = false;
    };
    redial_proxy = {
      url = "github:lucasew/redial_proxy";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixpkgsLatest, nixgram, nix-ld, home-manager, dotenv, nur, pocket2kindle, redial_proxy, ... }:
  let
    userSettings = import ./globalConfig.nix;
    system = "x86_64-linux";
    environmentShell = with userSettings; ''
      alias nixos-rebuild="sudo -E nixos-rebuild --flake '${rootPath}#acer-nix'"
      export NIXPKGS_ALLOW_UNFREE=1
      export NIX_PATH="nixos-config=${(builtins.toString rootPath) + "/nodes/acer-nix"}:nixpkgs=${nixpkgs}:dotfiles=${builtins.toString rootPath}:nixpkgsLatest=${nixpkgsLatest} home-manager=${home-manager}:nur=${nur}"

  '';
    overlays = [
      (import ./modules/zig/overlay.nix)
      (import ./overlay.nix)
    ];
    pkgs = import nixpkgs {
      inherit overlays;
      inherit system;
    };
  in {
    nixosConfigurations.acer-nix = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        "${home-manager}/nixos"
        "${nix-ld}/modules/nix-ld.nix"
        ({pkgs, ...}: {
            nixpkgs = {
              inherit overlays;
            };
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${userSettings.username} = {config, ...}: {
                systemd.user.services.redial_proxy = import ./lib/systemdUserService.nix {
                  description = "Redial proxy";
                  command = "${pkgs.callPackage redial_proxy {}}/bin/redial_proxy";
                };
                home.file.".dotfilerc".text = ''
                #!/usr/bin/env bash
                ${environmentShell}
                '';
                imports = [
                  ./nodes/acer-nix/home.nix
                  "${nixgram}/hmModule.nix"
                ];
              };
            };
          }
        )
        ./nodes/acer-nix/default.nix
      ];
    };
    packages = pkgs;
    devShell = pkgs.mkShell {
      name = "nixcfg-shell";
      buildInputs = [];
      shellHook = ''
        ${environmentShell}
        echo '${environmentShell}'
        echo Shell setup complete!
      '';
    };
  };
}
