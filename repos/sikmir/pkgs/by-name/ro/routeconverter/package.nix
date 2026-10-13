{
  lib,
  stdenv,
  fetchfromgh,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "routeconverter";
  version = "3.7";

  __structuredAttrs = true;

  srcs = [
    (fetchfromgh {
      owner = "cpesch";
      repo = "RouteConverter";
      tag = finalAttrs.version;
      hash = "sha256-F6mjh+Y5EZ/z1V2bmJ18z3NUJR/R9Bs6zic094pxg2Y=";
      name = "RouteConverterLinux.jar";
    })
    (fetchfromgh {
      owner = "cpesch";
      repo = "RouteConverter";
      tag = finalAttrs.version;
      hash = "sha256-+UgaRu4lnUqN2+jdoEci3/YNpRuBjTzIWyYMMx0Zw7E=";
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
