{ appimageTools, makeDesktopItem, fetchurl }:

let
  pname = "onlyoffice-desktopeditors";
  version = "5.6.0";
  name = "${pname}-${version}";

  src = fetchurl {
    url =
      "https://github.com/ONLYOFFICE/DesktopEditors/releases/download/ONLYOFFICE-DesktopEditors-${version}/DesktopEditors-x86_64.AppImage";
    sha256 = "19sjmp8qd2l0q6s9n7919d8wfzg9nfdw16k5dad5ai1373fdwgas";
  };

  appimageContents = appimageTools.extractType2 { inherit name src; };
in appimageTools.wrapType2 {
  inherit name src;
  extraPkgs = pkgs: with pkgs; [ libpulseaudio ];
  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/onlyoffice-desktopeditors.desktop $out/share/applications/onlyoffice-desktopeditors.desktop
    install -m 444 -D ${appimageContents}/asc-de.png $out/share/icons/hicolor/256x256/apps/asc-de.png
  '';
}
