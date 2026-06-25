# Overlay

`bun2nix` provides [an overlay](https://nixos.wiki/wiki/Overlays) which places the `bun2nix` binary (along with it's `passthru` functions) into `pkgs` for ease of use, where you can then use it in your `devShell` or with `pkgs.callPackage`, etc.

# Usage

Set up the `bun2nix` overlay as follows:

## Add the overlay

Instantiate `pkgs` with the `bun2nix` attribute included:

```nix
{ bun2nix, nixpkgs, ... }:
let
  pkgs = import inputs.nixpkgs {
    inherit system;
    overlays = [ inputs.bun2nix.overlays.default ];
  };
in
{ ... }
```

## Use `bun2nix` from `pkgs`

Use your freshly overlaid `pkgs` to build a `bun2nix` project:

```nix
{ pkgs, ... }:
pkgs.stdenv.mkDerivation {
  pname = "react-website";
  version = "1.0.0";

  src = ./.;

  nativeBuildInputs = [
    pkgs.bun2nix.hook
  ];

  bunDeps = pkgs.bun2nix.fetchBunDeps {
    bunNix = ./bun.nix;
  };

  buildPhase = ''
    bun run build \
      --minify
  '';

  installPhase = ''
    mkdir -p $out/dist

    cp -R ./dist $out
  '';
}
```

Or, to add the `bun2nix` binary to your `devShell`:

```nix
# In your flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    bun2nix.url = "github:nix-community/bun2nix";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, bun2nix, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          overlays = [ bun2nix.overlays.default ];
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            bun
            bun2nix
          ];
        };
      }
    );
}
```
