{ lib
, fetchurl
, mkElectronAppImage
, stdenv
, rp ? ""
}:

mkElectronAppImage rec {
  pname = "lx-music-desktop";
  version = "2.3.0";
  
  src = fetchurl {
    url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
    hash = "sha256-GzIzFLGSn0PE3DJEeJLY9MPrCPFK+5P0bVrV9ZW+84A=";
  };

  runtimeLibs = [ stdenv.cc.cc.lib ];

  meta = {
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}