{
  description = "nixcfg";

  inputs = {
    impermanence.url = "github:nix-community/impermanence";
    home-manager.url = "github:lucasew/home-manager";
    nix-ld.url = "github:Mic92/nix-ld";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgsLatest.url = "github:NixOS/nixpkgs/master";
    nur.url = "github:nix-community/NUR/master";
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
  with import ./globalConfig.nix;
  let
    system = "x86_64-linux";
    environmentShell = ''
      export NIXPKGS_ALLOW_UNFREE=1
      export NIX_PATH=nixpkgs=${nixpkgs}:nixpkgs-overlays=${builtins.toString rootPath}/compat/overlay.nix:nixpkgsLatest=${nixpkgsLatest}:home-manager=${home-manager}:nur=${nur}:nixos-config=${(builtins.toString rootPath) + "/nodes/$HOSTNAME/default.nix"}
  '';
    overlays = [
      (import ./overlay.nix)
    ];
    pkgs = import nixpkgs {
      inherit overlays;
      inherit system;
      config = {
      allowUnfree = true;
      };
    };
  in {
    inherit overlays;
    inherit environmentShell;
    nixosConfigurations.vps = nixpkgs.lib.nixosSystem {
      inherit pkgs;
      inherit system;
      modules = [
        ./nodes/vps/default.nix
      ];
    };
    nixosConfigurations.acer-nix = nixpkgs.lib.nixosSystem {
      inherit pkgs;
      inherit system;
      modules = [
        ./nodes/acer-nix/default.nix
      ];
    };
    packages = pkgs;
    devShell.x86_64-linux = pkgs.mkShell {
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
