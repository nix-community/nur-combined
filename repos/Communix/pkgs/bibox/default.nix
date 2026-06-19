{ pkgs, lib, ... }:
let
  pname = "bibox";
  version = "3.0.4";
  src = pkgs.fetchurl {
    url = "https://static.bibox2.westermann.de/electron/autoUpdate/BiBox%203.0.4.AppImage";
    sha256 = "sha256-dwmG+4f9I/EAI499hzpUt7cKqTbKwmCVV/PpAqfje4Y=";
  };

  biboxFiles = pkgs.appimageTools.extract {
    inherit pname version src;

    postExtract = ''
      substituteInPlace $out/bibox.desktop --replace-fail 'Exec=AppRun' 'Exec=bibox'
    '';
  };
in
pkgs.appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${biboxFiles}/bibox.desktop ''${out}/share/applications/bibox.desktop
    substituteInPlace ''${out}/share/applications/bibox.desktop --replace-fail "Icon=/usr/share/" "Icon=''${out}/share/"
    install -m 444 -D ${biboxFiles}/bibox.png ''${out}/share/icons/hicolor/0x0/apps/bibox2.png
  '';

  meta = {
    description = "";
    mainProgram = "bibox";
    downloadPage = "https://www.bibox.schule/download/";
    homepage = "https://www.bibox.schule/";
    license = lib.licenses.unfreeRedistributable;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
