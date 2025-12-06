{
  description = "Go development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    # Auto-updated Go versions (updated daily via GitHub Actions)
    matt = {
      url = "github:mattrobenolt/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, flake-utils, matt, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ matt.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            go-bin # Latest Go (auto-updated daily, currently 1.25.x)
            # Or use specific versions: go-bin_1_24, go-bin_1_25
            gopls
            # Add other tools: gotools, delve, etc.
          ];

          # Environment variables (optional)
          # GOEXPERIMENT = "jsonv2";

          shellHook = ''
            # Add project binaries to PATH
            export PATH="$PWD/bin:$PATH"
          '';
        };
      }
    );
}
