{ lib
, fetchurl
, mkElectronAppImage
, rp ? ""
}:

mkElectronAppImage rec {
  pname = "lx-music-desktop";
  version = "2.2.0";
  
  src = fetchurl {
    url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
    hash = "sha256-cJQSfwNQ3iOHwRKiBXBAHWqs+A3Mi33Y/kBqPCKOzSI=";
  };

  meta = {
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}