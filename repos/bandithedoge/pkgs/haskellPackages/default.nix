{
  pkgs ? import <nixpkgs> {},
  sources ?
    import ../../_sources/generated.nix {
      inherit (pkgs) fetchurl fetchgit fetchFromGitHub;
    },
}: let
  callHaskellPackage = pkg: {
    compiler ? "ghc902",
    attrs ? {},
  }:
    (pkgs.haskell.packages.${compiler}.callPackage pkg {}).overrideAttrs (oldAttrs: (
      {
        inherit (sources.${pkgs.lib.removeSuffix ".nix" (builtins.baseNameOf pkg)}) pname version src;
      }
      // attrs
    ));
in {
  taffybar = callHaskellPackage ./taffybar.nix {
    attrs = {
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
}
