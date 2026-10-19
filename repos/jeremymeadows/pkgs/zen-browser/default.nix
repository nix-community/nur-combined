{
  lib,
  pkgs,
  fetchurl,
  appimageTools,
}:

let
  pname = "zen";
  description = "Zen is a firefox-based browser with the aim of pushing your productivity to a new level!";
  version = "1.23.2b";

  src = fetchurl {
    url = "https://github.com/zen-browser/desktop/releases/download/${version}/zen-x86_64.AppImage";
    hash = "sha256-A2Nz9FtJUwOsK9Q8qBWgpnuXVxdvhrRZ0N6rSzcGkdA=";
  };

  lib = pkgs.lib;

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 rec {
  inherit pname version src;

  extraPkgs = pkgs: with pkgs; [
    ffmpeg
  ];

  extraInstallCommands = ''
    install -Dm444 \
      "${appimageContents}/${pname}.desktop" \
      "$out/share/applications/${pname}.desktop"

    install -Dm444 \
      "${appimageContents}/${pname}.png" \
      "$out/share/icons/hicolor/256x256/apps/${pname}.png"

    substituteInPlace "$out/share/applications/${pname}.desktop" \
      --replace "Exec=AppRun" "Exec=${pname}-linux-x86_64"
  '';

  meta = {
    description = "The browser for a calmer internet";
    homepage = "https://zen-browser.app/";
    downloadPage = "https://github.com/zen-browser/desktop/releases/latest/";
    license = lib.licenses.mpl20;
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
    platforms = [ "x86_64-linux" ];
    mainProgram = "zen";
  };
}
