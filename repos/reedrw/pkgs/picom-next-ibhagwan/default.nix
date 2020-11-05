{ lib, picom, fetchFromGitHub }:

picom.overrideAttrs (
  oldAttrs: rec {
    version = "next-ibhagwan";
    src = fetchFromGitHub (lib.importJSON ./source.json);

    meta = {
      description = "A picom fork with rounded corners and dual_kawase blur on all backends.";
      homepage = "https://github.com/yshui/picom/pull/361";
    };

  }
)

