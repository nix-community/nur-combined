{ lib, appimageTools, fetchurl }:

let
  pname = "amazing-marvin";
  version = "1.64.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url = "https://amazingmarvin.s3.amazonaws.com/Marvin-${version}.AppImage";
    sha256 = "sha256-YUnz+XqTroQW4ef/Stp+N8KhzZI1TXCO0KOfAUKQg8w=";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in
appimageTools.wrapType2 {
  inherit name src;

  extraPkgs = pkgs:
    with pkgs; [
      xorg.libXScrnSaver
      xorg.libXtst
      libappindicator-gtk2
      libnotify
    ];

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
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
