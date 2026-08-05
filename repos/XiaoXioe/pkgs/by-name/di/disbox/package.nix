{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "disbox";
  version = "4.9.2";

  src = fetchurl {
    url = "https://github.com/naufal-backup/disbox/releases/download/v${version}/Disbox-Linux-x64.AppImage";

    sha256 = "sha256-uWb4RSgph+YdDtHbtRPU0Nl7KC/RtCiyzv7WLjMbv0A=";
  };

  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''

    install -m 444 -D ${appimageContents}/usr/share/icons/hicolor/32x32/apps/disbox.png \
      $out/share/icons/hicolor/512x512/apps/disbox.png

    # Install file desktop
    install -m 444 -D ${appimageContents}/disbox.desktop $out/share/applications/disbox.desktop

    # Pastikan file desktop merujuk ke nama ikon yang benar
    substituteInPlace $out/share/applications/disbox.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}' \
      --replace 'Icon=disbox' 'Icon=disbox'
  '';

  meta = with lib; {
    description = "Aplikasi desktop penyimpanan awan modern yang memanfaatkan Discord";
    homepage = "https://github.com/naufal-backup/disbox";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
