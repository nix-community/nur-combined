{
  pkgs,
  sources,
  ...
}: let
  callHaskellPackage = pkg: {
    compiler ? "ghc902",
    tagged ? false,
    attrs ? {},
    cabal2nixAttrs ? {},
  }:
    (pkgs.haskell.packages.${compiler}.callPackage pkg cabal2nixAttrs).overrideAttrs (oldAttrs: (
      let
        source = sources.${pkgs.lib.removeSuffix ".nix" (pkgs.lib.removePrefix "_" (builtins.baseNameOf pkg))};
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
  taffybar = callHaskellPackage ./_taffybar.nix rec {
    compiler = "ghc92";
    cabal2nixAttrs = {
      gi-gtk-hs = pkgs.haskell.lib.dontHaddock pkgs.haskell.packages.${compiler}.gi-gtk-hs;
    };
    attrs = {
      meta.broken = true;
      doHaddock = false;
      doHoogle = false;
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

  xmonad-entryhelper = callHaskellPackage ./_xmonad-entryhelper.nix {};

  kmonad = callHaskellPackage ./_kmonad.nix {
    compiler = "ghc92";
    attrs = {
      nativeBuildInputs = with pkgs; [
        removeReferencesTo
        (writeShellScriptBin "git" ''
          echo ${sources.kmonad.version}
        '')
      ];
      dontCheck = true;
    };
  };
}
