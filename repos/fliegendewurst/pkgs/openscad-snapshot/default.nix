{ lib, fetchurl, appimageTools, openscad, makeWrapper, makeDesktopItem }:

let
  pname = "openscad";
  version = "2023.08.25.ai16051";
  src = fetchurl {
    url = "https://files.openscad.org/snapshots/OpenSCAD-${version}-x86_64.AppImage";
    sha256 = "sha256-mEGmkL2lL7JxK0nRPLtnfg4vxtkK3URz351eyuRHZPE=";
  };

  desktopItem = makeDesktopItem {
    name = "OpenSCAD";
    exec = "${pname}-${version} %f";
    comment = "The Programmers Solid 3D CAD Modeller (development snapshot)";
    icon = "openscad-nightly";
    desktopName = "OpenSCAD";
    genericName = "OpenSCAD";
    mimeTypes = [ "application/x-openscad" ];
    categories = [ "Graphics" "3DGraphics" "Engineering" ];
    keywords = [ "3d" "solid" "geometry" "csg" "model" "stl"];
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    source "${makeWrapper}/nix-support/setup-hook"
    wrapProgram $out/bin/${pname}-${version} \
        --unset QT_PLUGIN_PATH

    mkdir -p $out/share
    cp -rt $out/share ${desktopItem}/share/applications ${appimageContents}/usr/share/icons
  '';

  meta = with lib; {
    inherit (openscad.meta) description longDescription homepage license;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
