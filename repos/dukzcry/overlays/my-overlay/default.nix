nur: self: super:
{
  # https://github.com/NixOS/nixpkgs/pull/103485
  zoom-us = super.zoom-us.overrideAttrs (oldAttrs: rec {
    runtimeDependencies = oldAttrs.runtimeDependencies ++ [ super.alsaLib ];
  });
  # https://github.com/NixOS/nixpkgs/issues/98009
  qt515 = super.qt515.overrideScope' (selfx: superx: {
    qtbase = superx.qtbase.overrideAttrs (old: {
      patches = (old.patches or []) ++ super.lib.optional (builtins.compareVersions super.qt515.qtbase.version "5.15.0" == 0) [
        ./7218665.diff
      ];
    });
  });
  libsForQt512 = super.libsForQt512 // {
    adwaita-qt = with super; libsForQt512.callPackage <nixpkgs/pkgs/data/themes/adwaita-qt> {
      mkDerivation = stdenv.mkDerivation;
    };
  };
  libsForQt514 = super.libsForQt514 // {
    adwaita-qt = with super; libsForQt514.callPackage <nixpkgs/pkgs/data/themes/adwaita-qt> {
      mkDerivation = stdenv.mkDerivation;
    };
  };
}
