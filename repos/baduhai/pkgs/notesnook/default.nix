{ lib, fetchurl, appimageTools }:

let
  pname = "notesnook";
  version = "2.4.2";
  src = fetchurl {
    url = "https://github.com/streetwriters/notesnook/releases/download/v2.4.2/notesnook_linux_x86_64.AppImage";
    sha256 = "sha256-wL93N105CgylaFlSIKXN4B/MWLw+PLquIz8E2e8RXOM=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname src version; };
in

appimageTools.wrapType2 {
  inherit pname src version;

  extraPkgs = pkgs: with pkgs; [
    ffmpeg
  ];

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/notesnook.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/notesnook.desktop --replace 'Exec=AppRun --no-sandbox' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "A fully open source & end-to-end encrypted note taking app.";
    homepage = "https://notesnook.com";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
