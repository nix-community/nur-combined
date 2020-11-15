with import <nixpkgs> {};

let

  sources = import ./nix/sources.nix;

  devshell = import "${sources.devshell}/overlay.nix";

  nur-overlay = self: super: {
    nix-prefetch = super.nix-prefetch.overrideAttrs (
      old: rec {
        src = sources.nix-prefetch;
        patches = [];
      }
    );

    nix-update = super.nix-update.overrideAttrs (
      old: rec {
        makeWrapperArgs = [
          "--prefix" "PATH" ":" (lib.makeBinPath [nix self.nix-prefetch])
        ];
      }
    );
  };

  pkgs = import <nixpkgs> {
    inherit system;
    overlays = [
      devshell
      nur-overlay
    ];
  };


in
pkgs.mkDevShell.fromTOML ./devshell.toml

