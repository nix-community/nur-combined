{
  lib,
  pkgs,
  ...
}:
pkgs.appimageTools.wrapType2 rec {
  pname = "mtgatool-desktop";
  version = "6.7.5";

  src = pkgs.fetchurl {
    url = "https://github.com/mtgatool/mtgatool-desktop/releases/download/v${version}/mtgatool-desktop-${version}.AppImage";
    hash = "sha256-xNw8oT1BYmmsq861pIZsOBdj1hh0G32d5gJBwMwlJiY=";
  };

  nativeBuildInputs = with pkgs; [
    makeWrapper
  ];

  extraInstallCommands =
    let
      contents = pkgs.appimageTools.extractType2 { inherit pname version src; };
    in
    ''
      mkdir -p "$out/share/applications"
      mkdir -p "$out/share/lib/mtgatool-desktop"
      cp -r ${contents}/{locales,resources} "$out/share/lib/mtgatool-desktop"
      cp -r ${contents}/usr/share/* "$out/share"
      cp "${contents}/${pname}.desktop" "$out/share/applications/"
      wrapProgram $out/bin/mtgatool-desktop --add-flags "--ozone-platform=wayland"
      substituteInPlace $out/share/applications/${pname}.desktop --replace-fail 'Exec=AppRun' 'Exec=${meta.mainProgram}'
    '';

  meta = {
    description = "MTGATool - MTG Arena Tracker";
    homepage = "https://mtgatool.com";
    license = lib.licenses.gpl3Only;
    mainProgram = "mtgatool-desktop";
  };
}
