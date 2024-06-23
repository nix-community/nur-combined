{
  pkgs,
  sources,
  ...
}:
pkgs.stdenv.mkDerivation {
  inherit (sources.vgmtrans) pname src;
  version = sources.vgmtrans.date;

  nativeBuildInputs = with pkgs; [
    cmake
    qt6.wrapQtAppsHook
  ];

  buildInputs = with pkgs; [
    qt6.qtbase
    qt6.qtsvg
  ];

  postBuild =
    ''
      mkdir -p $out/lib
    ''
    + (
      if pkgs.stdenv.isAarch64
      then ''
        cp $src/lib/bass/aarch64/*.so $out/lib/
      ''
      else ''
        cp $src/lib/bass/*.so $out/lib/
      ''
    );

  meta = with pkgs.lib; {
    description = "A tool to convert proprietary, sequenced videogame music to industry-standard formats";
    homepage = "https://github.com/vgmtrans/vgmtrans";
    license = licenses.zlib;
    platforms = platforms.linux;
  };
}
