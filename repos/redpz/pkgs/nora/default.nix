{ appimageTools, fetchurl }:
let
  pname = "nora";
  version = "3.1.0";

  src = fetchurl {
    url = "https://github.com/Sandakan/Nora/releases/download/v${version}-stable/Nora.v${version}-stable-linux-x86_64.AppImage";
    hash = "sha256-1bdasMLSmb2ra3fq5i/g9iAmEelRUacFeIVQZ0MCY2U=";
  };

  appimageContents = appimageTools.extract {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}
    install -m 444 -D ${appimageContents}/Nora.desktop $out/share/applications/Nora.desktop
    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/512x512/apps/Nora.png \
      $out/share/icons/hicolor/512x512/apps/Nora.png
    substituteInPlace $out/share/applications/Nora.desktop \
      --replace-fail 'Exec=AppRun' 'Exec=${pname}'
  '';
}
