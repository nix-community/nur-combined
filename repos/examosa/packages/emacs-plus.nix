{
  emacs,
  emacs-unstable ? emacs,
  fetchFromGitHub,
  lib,
}: let
  src = fetchFromGitHub {
    owner = "d12frosted";
    repo = "homebrew-emacs-plus";
    rev = "df3c93cb16f9770e0747adc424a477fb68f026b8";
    hash = "sha256-OAbS5/rv9dNmtFy/oQVLL4jToYN20YvULk4ox8fvQ5Q=";
  };

  majorVersion = lib.versions.major (lib.getVersion emacs-unstable);
in
  emacs-unstable.overrideAttrs (oldAttrs: {
    pname = "emacs-plus";

    patches =
      oldAttrs.patches
      ++ map (patch: src + /patches/emacs-${majorVersion}/${patch}.patch) [
        "fix-ns-x-colors"
        "round-undecorated-frame"
        "system-appearance"
      ];

    # https://github.com/d12frosted/homebrew-emacs-plus#icons
    postPatch =
      oldAttrs.postPatch
      + ''
        cp ${src}/community/icons/memeplex-wide/icon.icns nextstep/Cocoa/Emacs.base/Contents/Resources/Emacs.icns
      '';

    meta = oldAttrs.meta // {platforms = lib.platforms.darwin;};
  })
