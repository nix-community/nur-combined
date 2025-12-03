{
  appimageTools,
  lib,
  fetchurl,
}:
let
  pname = "iptvnator";
  version = "0.16.0";
  src = fetchurl {
    url = "https://github.com/4gray/iptvnator/releases/download/v${version}/${pname}-${version}.AppImage";
    hash = "sha256-KQRbr5vxhuiRANZ2LRx2YR8LkrQP94LCUWz3vnKunHo=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -Dm444 ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "Video player application that provides support for the playback of IPTV playlists";
    homepage = "https://github.com/4gray/iptvnator";
    changelog = "https://github.com/4gray/iptvnator/releases/tag/v${version}";
    license = licenses.mit;
    mainProgram = "iptvnator";
    platforms = [ "x86_64-linux" ];
  };
}
