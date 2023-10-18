{ lib, appimageTools, fetchurl }:

appimageTools.wrapType2 rec {
  pname = "quiet";
  version = "1.9.5";
  src = fetchurl {
    url = "https://github.com/TryQuiet/quiet/releases/download/quiet%40${version}/Quiet-${version}.AppImage";
    hash = "sha256-fYuZMCYHcgryWuzMtsT8m5S6NYg/tYWxsFvKoZfxHQE=";
  };

  meta = with lib; {
    description = "Alternative to team chat apps like Slack, Discord, and Element that does not require trusting a central server or running one's own";
    homepage = "https://github.com/TryQuiet/quiet";
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with sourceTypes; [ binaryNativeCode ];
    maintainers = with maintainers; [ mikaelfangel ];
    mainProgram = "quiet";
  };
}
