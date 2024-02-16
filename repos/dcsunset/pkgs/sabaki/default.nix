{ lib
, appimageTools
, fetchurl
}:

let
  pname = "sabaki";
  version = "0.52.2";

  src = fetchurl {
    url = "https://github.com/SabakiHQ/Sabaki/releases/download/v${version}/sabaki-v${version}-linux-x64.AppImage";
    hash = "sha256-wuCj5HvNZc2KOdc5O49upNToFDKiMMWexykctHi51EY=";
  };
in appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    mv $out/bin/${pname}-${version} $out/bin/${pname}
  '';

  meta = with lib; {
    description = "An elegant Go board and SGF editor for a more civilized age";
    homepage = "https://github.com/SabakiHQ/Sabaki";
    license = licenses.mit;
  };
}
