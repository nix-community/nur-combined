{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };
  outputs = {
    self,
    nixpkgs,
    flake-utils,
  }:
    (flake-utils.lib.eachDefaultSystem (system: {
      packages =
        import ./default.nix {pkgs = import nixpkgs {inherit system;};};
    }))
    // {
      overlays.default = import ./overlay.nix;
    };
}
