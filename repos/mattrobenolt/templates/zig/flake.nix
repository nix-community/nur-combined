{
  description = "Zig development environment";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    mattrobenolt.url = "github:mattrobenolt/nixpkgs";
  };

  outputs =
    { nixpkgs
    , flake-utils
    , mattrobenolt
    , ...
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ mattrobenolt.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            zig_0_15
            zls_0_15
            zlint
          ];

          shellHook = ''
            # Zig doesn't understand nix's macro-prefix-map flags, causes warnings
            # See: https://github.com/ziglang/zig/issues/18998
            # Note: We keep NIX_LDFLAGS for library paths, only unset NIX_CFLAGS_COMPILE
            unset NIX_CFLAGS_COMPILE
          '';
        };
      }
    );
}
