{ lib
, fetchurl
, mkElectronAppImage
, stdenv
, rp ? ""
}:

mkElectronAppImage rec {
  pname = "lx-music-desktop";
  version = "2.6.0";
  
  src = fetchurl {
    url = "${rp}https://github.com/lyswhut/${pname}/releases/download/v${version}/${pname}_${version}_x64.AppImage";
    hash = "sha256-c6+miV4vdRNb6AEZLff1Zq/YZYiwyJyO1xozir+zh6A=";
  };

  runtimeLibs = [ stdenv.cc.cc.lib ];

  meta = {
    description = "A music application based on electron";
    homepage = "https://lxmusic.toside.cn";
    license = lib.licenses.asl20;
    platforms = [ "x86_64-linux" ];
    sourceProvenance = with lib.sourceTypes; [ binaryNativeCode ];
  };
}