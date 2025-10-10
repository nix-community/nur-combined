{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "amazing-marvin";
  version = "1.68.0";

  src = fetchurl {
    url = "https://amazingmarvin.s3.amazonaws.com/Marvin-${version}.AppImage";
    sha256 = "sha256-c6ql3loog0nU7dcCHe5ba7PEhcyQ+MwTTIAKKT5aOB4=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname src version; };
in
appimageTools.wrapType2 {
  inherit pname src version;

  extraPkgs =
    pkgs: with pkgs; [
      xorg.libXScrnSaver
      xorg.libXtst
      libappindicator-gtk2
      libnotify
    ];

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/marvin.desktop $out/share/applications/marvin.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/marvin.png \
      $out/share/icons/hicolor/512x512/apps/marvin.png
    substituteInPlace $out/share/applications/marvin.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
  '';

  meta = with lib; {
    description = "Feature rich and customizable personal to-do app.";
    homepage = "https://amazingmarvin.com/";
    license = licenses.unfree;
    maintainers = with maintainers; [ lunik1 ];
    platforms = [ "x86_64-linux" ];
  };
}
