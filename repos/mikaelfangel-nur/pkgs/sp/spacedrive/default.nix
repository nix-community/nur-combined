{ lib, appimageTools, fetchurl, pkgs }:

appimageTools.wrapType2 rec { # or wrapType1
  name = "spacedrive";
  version = "0.1.1";
  src = fetchurl {
    url = "https://github.com/spacedriveapp/spacedrive/releases/download/${version}/Spacedrive-linux-x86_64.AppImage";
    hash = "sha256-LGlBnz0+AN6Oc85csMFhaby8jag9jgVErhuU1dpHpMI=";
  };

  extraPkgs = pkgs: with pkgs; [ libthai ];

  meta = {
    description = "An open source file manager, powered by a virtual distributed filesystem (VDFS) written in Rust";
    homepage = "https://www.spacedrive.com/";
    mainProgram = name;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}
