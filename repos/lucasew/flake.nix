{
  description = "nixcfg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsLatest.url = "github:NixOS/nixpkgs/master";
    home-manager.url = "github:nix-community/home-manager";
    nur.url = "github:nix-community/NUR/master";
    nix-ld.url = "github:Mic92/nix-ld";
    nixgram = {
      url = "github:lucasew/nixgram/master";
      flake = false;
    };
    dotenv = {
      url = "github:lucasew/dotenv";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, nixgram, nix-ld, home-manager, dotenv, nur, ... }:
  let
    userSettings = import ./globalConfig.nix;
    system = "x86_64-linux";
    overlays = [
      # dotenv
      (self: super: 
      let
        dotenvBin = super.callPackage dotenv {};
        wrapDotenv = (file: script:
        let
          dotenvFile = (builtins.toString userSettings.rootPath + "/secrets/" + (builtins.toString file));
          command = super.writeShellScript "dotenv-wrapper" script;
        in ''
          ${dotenvBin}/bin/dotenv "@${builtins.toString dotenvFile}" -- ${command} $*
        '');
      in 
      {dotenv = dotenvBin; inherit wrapDotenv;})
      # nur
      (self: super: {
        nur = import nur {
          nurpkgs = super.pkgs;
          inherit (super) pkgs;
        };
      })
      (import ./modules/neovim/overlay.nix)
      (import ./modules/comby/overlay.nix)
      (import ./modules/custom_rofi/overlay.nix)
      (import ./modules/latest/overlay.nix)
      (import ./modules/minecraft/overlay.nix)
      (import ./modules/mspaint/overlay.nix)
      (import ./modules/node_clis/overlay.nix)
      (import ./modules/pinball/overlay.nix)
      (import ./modules/stremio/overlay.nix)
      (import ./modules/zig/overlay.nix)
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
        ({...}: {
            nixpkgs = {
              inherit overlays;
            };
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${userSettings.username} = {...}: {
                imports = [
                  ./nodes/acer-nix/home.nix
                  "${nixgram}/hmModule.nix"
                  ./modules/dotfiles/home.nix
                ];
              };
            };
          }
        )
        ./nodes/acer-nix/default.nix
      ];
    };
    shell =
    let
      rootPath = (import ./globalConfig.nix).rootPath;
    in pkgs.mkShell {
      name = "nixcfg-shell";
      shellHook = ''
        alias nixos-rebuild="sudo -E nixos-rebuild --flake '${rootPath}#acer-nix'"
        echo Shell setup complete!
      '';
    };
  };
}
