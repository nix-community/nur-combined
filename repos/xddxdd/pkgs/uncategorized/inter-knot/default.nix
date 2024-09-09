{
  sources,
  lib,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
  unzip,
  # Dependencies
  at-spi2-atk,
  cairo,
  gdk-pixbuf,
  glib,
  gtk3,
  harfbuzz,
  pango,
  ...
}:
stdenv.mkDerivation {
  inherit (sources.inter-knot) pname version src;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
    unzip
  ];

  buildInputs = [
    at-spi2-atk
    cairo
    gdk-pixbuf
    glib
    gtk3
    harfbuzz
    pango
    stdenv.cc.cc.lib
  ];

  installPhase = ''
    mkdir -p $out/bin $out/opt
    cp -r * $out/opt/
    chmod +x $out/opt/inter-knot
    makeWrapper $out/opt/inter-knot $out/bin/inter-knot
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "绳网是一个游戏、技术交流平台";
    homepage = "https://inot.top";
    license = lib.licenses.mit;
    platforms = [ "x86_64-linux" ];
  };
}
