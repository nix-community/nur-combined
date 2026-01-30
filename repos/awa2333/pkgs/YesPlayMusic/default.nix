{ lib
, appimageTools
, fetchurl
, libxshmfence
,
}:
appimageTools.wrapType2 rec {
  pname = "YesPlayMusic";
  version = "0.4.10";
  src = fetchurl {
    url = "https://github.com/qier222/${pname}/releases/download/v${version}/${pname}-${version}.AppImage";
    hash = "sha256-Qj9ZQbHqzKX2QBlXWtey/j/4PqrCJCObdvOans79KW4=";
  };
  extraPkgs = pkgs: [
    libxshmfence
  ];
  meta = {
    description = "A third party music application for Netease Music.(Use system-wide electron).高颜值的第三方网易云播放器.";
    homepage = "https://github.com/qier222/YesPlayMusic";
    license = lib.licenses.mit;
    mainProgram = "YesPlayMusic";
    platforms = lib.platforms.linux;
    sourceProvenance = [ lib.sourceTypes.binaryNativeCode ];
  };
}
