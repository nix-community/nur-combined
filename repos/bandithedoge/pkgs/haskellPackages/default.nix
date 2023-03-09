{
  pkgs ? import <nixpkgs> {},
  sources ?
    import ../../_sources/generated.nix {
      inherit (pkgs) fetchurl fetchgit fetchFromGitHub;
    },
}: let
  callHaskellPackage = pkg: {
    compiler ? "ghc902",
    tagged ? false,
    attrs ? {},
    cabal2nixAttrs ? {},
  }:
    (pkgs.haskell.packages.${compiler}.callPackage pkg cabal2nixAttrs).overrideAttrs (oldAttrs: (
      let
        source = sources.${pkgs.lib.removeSuffix ".nix" (builtins.baseNameOf pkg)};
      in
        {
          inherit (source) pname src;
          version =
            if tagged
            then source.version
            else source.date;
        }
        // attrs
    ));
in {
  taffybar = callHaskellPackage ./taffybar.nix rec {
    compiler = "ghc924";
    cabal2nixAttrs = {
      gi-gtk-hs = pkgs.haskell.lib.dontHaddock pkgs.haskell.packages.${compiler}.gi-gtk-hs;
    };
    attrs = {
      dontHaddock = true;
      nativeBuildInputs = with pkgs; [
        gcc
        pkg-config
        removeReferencesTo
      ];
      buildInputs = with pkgs; [
        cairo
        gnome2.pango
        gobject-introspection
        gtk3
        hicolor-icon-theme
        libdbusmenu
        libdbusmenu-gtk3
        libxml2
        xorg.libX11
        xorg.libXScrnSaver
        xorg.libXext
        xorg.libXinerama
        xorg.libXrandr
        xorg.libXrender
        zlib
      ];
    };
  };

  xmonad-entryhelper = callHaskellPackage ./xmonad-entryhelper.nix {};

  kmonad = callHaskellPackage ./kmonad.nix {
    compiler = "ghc926";
    attrs = {
      nativeBuildInputs = with pkgs; [
        removeReferencesTo
        (writeShellScriptBin "git" ''
          echo ${sources.kmonad.version}
        '')
      ];
    };
  };
}
