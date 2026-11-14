{
  lib,
  appimageTools,
  fetchurl,
}:

let
  pname = "amazing-marvin";
  version = "1.71.4";

  src = fetchurl {
    url = "https://amazingmarvin.s3.amazonaws.com/Marvin-${version}.AppImage";
    sha256 = "52cfa8168109060b7ec31f81a755deae401990176c13869d5e5f0e128f06b818";
  };

  appimageContents = appimageTools.extract { inherit pname src version; };
in
appimageTools.wrapType2 {
  inherit pname src version;

  extraPkgs =
    pkgs: with pkgs; [
      xorg.libXScrnSaver
      xorg.libXtst
      libappindicator
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
