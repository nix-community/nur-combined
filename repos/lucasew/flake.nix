{
  description = "nixcfg";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsLatest.url = "github:NixOS/nixpkgs/master";
    home-manager.url = "github:lucasew/home-manager";
    nur.url = "github:nix-community/NUR/master";
    nix-ld.url = "github:Mic92/nix-ld";
    rust-overlay.url = "github:oxalica/rust-overlay";
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
    zls = {
      url = "github:zigtools/zls";
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
      export NIX_PATH="nixos-config=${(builtins.toString rootPath) + "/nodes/acer-nix"}:nixpkgs=${nixpkgs}:dotfiles=${builtins.toString rootPath}:nixpkgsLatest=${nixpkgsLatest}:home-manager=${home-manager}:nur=${nur}:nixpkgs-overlays=${(builtins.toString rootPath) + "/compat/overlay.nix"}"

  '';
    overlays = [
      (import ./overlay.nix)
    ];
    pkgs = import nixpkgs {
      inherit overlays;
      inherit system;
    };
  in {
    inherit overlays;
    inherit environmentShell;
    nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ./nodes/vps/default.nix
      ];
    };
    nixosConfigurations.acer-nix = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
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
