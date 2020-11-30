nur: self: super:
{
  # https://github.com/NixOS/nixpkgs/pull/103485
  zoom-us = super.zoom-us.overrideAttrs (oldAttrs: rec {
    runtimeDependencies = oldAttrs.runtimeDependencies ++ [ super.alsaLib ];
  });
  # https://github.com/NixOS/nixpkgs/issues/98009
  qt515 = super.qt515.overrideScope' (selfx: superx: {
    qtbase = superx.qtbase.overrideAttrs (old: {
      patches = (old.patches or []) ++ [
        (super.fetchpatch {
          url = "https://codereview.qt-project.org/gitweb?p=qt/qtbase.git;a=patch;h=7218665699e31ac8eebab17afd684d1a56d12ac3";
          name = "Ensure-styles-always-get-to-polish-the-application-palette";
          sha256 = "1nwpds9rd7sfx7mw79d2vk3xynnqijn36mgvi7c8kyss1hp7g6iz";
        })
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
