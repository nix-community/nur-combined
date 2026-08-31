{
  lib,
  stdenv,
  fetchfromgh,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "routeconverter";
  version = "3.6";

  __structuredAttrs = true;

  srcs = [
    (fetchfromgh {
      owner = "cpesch";
      repo = "RouteConverter";
      tag = finalAttrs.version;
      hash = "sha256-QMeR9XmAAHf05fKnUF/S/0S8G9g0HjcF+iC9QGZfOBc=";
      name = "RouteConverterLinux.jar";
    })
    (fetchfromgh {
      owner = "cpesch";
      repo = "RouteConverter";
      tag = finalAttrs.version;
      hash = "sha256-CwEfGEG/Vbmn4hiTNGgOrj1LuxLd6J/vvMB8TytpYTE=";
      name = "RouteConverterCmdLine.jar";
    })
  ];

  nativeBuildInputs = [ makeWrapper ];

  buildInputs = [ jre ];

  dontUnpack = true;

  installPhase = ''
    install -dm755 $out/bin
    for _src in $srcs; do
      install -Dm644 "$_src" $out/share/java/$(stripHash "$_src")
    done

    makeWrapper ${jre}/bin/java $out/bin/routeconverter \
      --add-flags "-jar $out/share/java/RouteConverterLinux.jar"

    makeWrapper ${jre}/bin/java $out/bin/routeconverter-cli \
      --add-flags "-jar $out/share/java/RouteConverterCmdLine.jar"
  '';

  meta = {
    description = "A free tool to edit and convert routes, tracks and waypoints";
    homepage = "https://www.routeconverter.com/";
    sourceProvenance = with lib.sourceTypes; [ binaryBytecode ];
    license = lib.licenses.gpl2Plus;
    maintainers = [ lib.maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
})
