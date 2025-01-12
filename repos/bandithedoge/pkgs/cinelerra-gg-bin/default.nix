{
  pkgs,
  sources,
  ...
}:
pkgs.appimageTools.wrapType2 {
  inherit (sources.cinelerra-gg) pname version src;

  extraPkgs = pkgs':
    with pkgs'; [
      libpng
    ];

  meta = with pkgs.lib; {
    description = "Cinelerra GG Infinity is a free and open source video editing software for Linux. It handles rendering, compositing, motion tracking, video editing and much more.";
    homepage = "https://www.cinelerra-gg.org/";
    license = licenses.gpl2;
    platforms = ["x86_64-linux"];
    sourceProvenance = [sourceTypes.binaryNativeCode];
  };
}
