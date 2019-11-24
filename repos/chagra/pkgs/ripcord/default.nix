{ lib, appimageTools, fetchurl }:
let
  pname = "Ripcord";
  version = "0.4.20";
in appimageTools.wrapType2 rec {
  name = "ripcord";
  src = fetchurl {
    url = "https://cancel.fm/dl/${pname}-${version}-x86_64.AppImage";
    sha256 = "07fvm6qg1wmabcvyx5a9brfia6gljxx2cn6ynrm4rgk486chsc1s";
  };

  profile = ''
    export QT_QPA_PLATFORM=xcb
    export RIPCORD_ALLOW_UPDATES=0
  '';

  meta = with lib; {
    description = "Desktop chat client for group-centric services like Slack and Discord";
    homepage = https://cancel.fm/ripcord/;
    license.free = false;
    platforms = [ "x86_64-linux" ];
  };
}
