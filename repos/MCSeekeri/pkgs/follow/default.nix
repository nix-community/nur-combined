{
  lib,
  fetchurl,
  appimageTools,
}:

let
  pname = "follow";
  version = "1.12.0";
  src = fetchurl {
    url = "https://github.com/RSSNext/Folo/releases/download/desktop/v${version}/Folo-${version}-linux-x64.AppImage";
    hash = "sha256-rH5rWskNDvse3bO28dMzuhkdbEI/MtYDBNdC+EVP97I=";
  };
  appimageContents = appimageTools.extractType2 { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 644 -D ${appimageContents}/Folo.desktop -t $out/share/applications/
    install -m 644 -D ${appimageContents}/Folo.png $out/share/pixmaps/ 2>/dev/null || true
    cp -r ${appimageContents}/usr/share/icons $out/share/ 2>/dev/null || true
  '';

  meta = {
    description = "Next generation information browser";
    homepage = "https://github.com/RSSNext/Folo";
    changelog = "https://github.com/RSSNext/Folo/releases/tag/desktop/v${version}";
    license = lib.licenses.agpl3Only;
    mainProgram = "follow";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    maintainers = with lib.maintainers; [ MCSeekeri ];
  };
}
