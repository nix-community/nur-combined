{ lib, fetchurl, appimageTools, openscad, makeDesktopItem }:

let
  pname = "openscad";
  version = "2024.10.23.ai20994";
  src = fetchurl {
    url = "https://files.openscad.org/snapshots/OpenSCAD-${version}-x86_64.AppImage";
    hash = "sha256-2iltY9JcyfCn6IvoSRBlZy3ugt8UWjchYp3B7nW8hMo=";
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
    mkdir -p $out/share
    cp -rt $out/share ${desktopItem}/share/applications ${appimageContents}/usr/share/icons
  '';

  meta = with lib; {
    inherit (openscad.meta) description longDescription homepage license;
    platforms = [ "x86_64-linux" ];
    maintainers = with maintainers; [ fliegendewurst ];
  };
}
