{ lib
, fetchurl
, mkElectronAppImage
, stdenv
, rp ? ""
}:

mkElectronAppImage rec {
  pname = "lx-music-desktop";
  version = "2.2.2";
  
  src = fetchurl {
    url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}-v${version}-x64.AppImage";
    hash = "sha256-RX8RBgv/3vAxKSo0BO2t8DXpdt8RXdLmcRotQZ/sE+4=";
  };

  runtimeLibs = [ stdenv.cc.cc.lib ];

  meta = {
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
  };
}