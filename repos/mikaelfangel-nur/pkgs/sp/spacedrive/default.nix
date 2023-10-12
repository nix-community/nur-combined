{ lib, appimageTools, fetchurl, pkgs }:

appimageTools.wrapType2 rec { # or wrapType1
  name = "spacedrive";
  version = "0.1.0";
  src = fetchurl {
    url = "https://github.com/spacedriveapp/spacedrive/releases/download/${version}/Spacedrive-linux-x86_64.AppImage";
    hash = "sha256-JQRMRgIaGLUCBX6Wtu953HO2SoZDrfLNkOlpPVOAyW8=";
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
