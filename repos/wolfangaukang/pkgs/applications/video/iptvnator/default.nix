{ appimageTools, lib, fetchurl }:
let
  pname = "iptvnator";
  version = "0.12.0";
  src = fetchurl {
    url = "https://github.com/4gray/iptvnator/releases/download/v${version}/${pname}-${version}.AppImage";
    sha256 = "sha256-mTm711i1IjK5FfGgGJ40QvZCeubN3k/h8Q73wj7pdSE=";
  };

  appimageContents = appimageTools.extract { inherit pname version src; };
in appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}

    install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
    substituteInPlace $out/share/applications/${pname}.desktop \
      --replace 'Exec=AppRun' 'Exec=${pname}'
    cp -r ${appimageContents}/usr/share/icons $out/share
  '';

  meta = with lib; {
    description = "Video player application that provides support for the playback of IPTV playlists";
    homepage = "https://github.com/4gray/iptvnator";
    license = licenses.mit;
    maintainers = with maintainers; [ wolfangaukang ];
    platforms = [ "x86_64-linux" ];
  };
}
