{
  description = "Python development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mattware = {
      url = "github:mattrobenolt/nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, flake-utils, mattware, ... }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ mattware.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          venvDir = ".venv";
          packages = with pkgs; [
            uv
            uvShellHook
          ];

          UV_PYTHON_PREFERENCE = "only-managed";
        };

      }
    );
}
