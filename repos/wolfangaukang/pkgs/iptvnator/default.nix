{ appimageTools, lib, fetchurl }:
let
  pname = "iptvnator";
  version = "0.9.0";
  name = "${pname}-${version}";
  src = fetchurl {
    url = "https://github.com/4gray/iptvnator/releases/download/v${version}/${name}.AppImage";
    sha256 = "sha256-ShHIZFqZkO6+FribJj+tRiQWSRMhUWX6GNFs/0sAR0k=";
  };

  appimageContents = appimageTools.extract { inherit name src; };
in appimageTools.wrapType2 {
  inherit name src;

  extraInstallCommands = ''
    mv $out/bin/${name} $out/bin/${pname}

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
