{ lib, appimageTools, fetchurl }:

let
  pname = "dbx";
  version = "0.6.48";
  src = fetchurl {
    url = "https://github.com/t8y2/dbx/releases/download/v${version}/DBX_${version}_amd64.AppImage";
    hash = "sha256-5B52IrelmYd8BcsJdhGZe1NOxiymr7vM055WcfpjgVw=";
  };
  contents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  # Host GIO modules may require a newer GLib than the AppImage bundles.
  profile = ''
    unset GIO_EXTRA_MODULES
  '';

  extraInstallCommands = ''
    install -Dm644 ${contents}/DBX.desktop "$out/share/applications/dbx.desktop"
    substituteInPlace "$out/share/applications/dbx.desktop" \
      --replace-fail 'Exec=dbx %U' "Exec=$out/bin/dbx %U"
    install -Dm644 ${contents}/dbx.png "$out/share/icons/hicolor/128x128/apps/dbx.png"
  '';

  meta = {
    description = "DBX database management tool (official prebuilt AppImage)";
    homepage = "https://github.com/t8y2/dbx";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    mainProgram = "dbx";
  };
}
