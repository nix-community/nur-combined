{
  description = "My personal NUR repository";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, fenix }:
    let
      systems = [
        "x86_64-linux"
        # "i686-linux"
        # "x86_64-darwin"
        # "aarch64-linux"
        # "armv6l-linux"
        # "armv7l-linux"
      ];
      genSystems = nixpkgs.lib.genAttrs systems;

      pkgs = genSystems
        (system:
          import nixpkgs {
            inherit system;
            config = {
              # contentAddressedByDefault = true;
            };
            overlays = [ fenix.overlays.default ];
          }
        );
    in
    {
      inherit pkgs;
      packages = genSystems (system: import ./default.nix { flake-enabled = true; pkgs = pkgs.${system}; });
    };
}


