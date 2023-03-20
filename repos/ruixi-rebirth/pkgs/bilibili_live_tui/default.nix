{ lib
, fetchurl
, stdenv
}:

stdenv.mkDerivation rec {
  pname = "bilibili_live_tui";
  version = "20230111";

  src = fetchurl {
    url = "https://github.com/yaocccc/bilibili_live_tui/releases/download/v${version}/bili_tui_tui";
    sha256 = "sha256-9SMm0wWd4JXdz8tTzuMkZVzcwkYO9T2keIk6+jL7OFo=";
  };

  dontUnpack = true;
  installPhase = ''
    install -m755 -D $src $out/bin/bili_tui_tui
  '';
  meta = with lib; {
    description = "终端下使用的bilibili弹幕获取和弹幕发送服务";
    homepage = "https://github.com/yaocccc/bilibili_live_tui";
    mainProgram = "bili_tui_tui";
    platforms = platforms.linux;
  };
}
