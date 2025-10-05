{
  lib,
  stdenv,
  fetchurl,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "routeconverter";
  version = "3.1";

  srcs = [
    (fetchurl {
      url = "https://static.routeconverter.com/download/previous-releases/${finalAttrs.version}/RouteConverterLinuxOpenSource.jar";
      hash = "sha256-noGM3Vwv8O7EWMnqhkctA7gyB+So5pZyzfatjt0KN54=";
    })
    (fetchurl {
      url = "https://static.routeconverter.com/download/previous-releases/${finalAttrs.version}/RouteConverterCmdLine.jar";
      hash = "sha256-EMnSeeklQyQkWBJFZmHm58RbPJTrhQx2qtO0rXTa4HA=";
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
      --add-flags "-jar $out/share/java/RouteConverterLinuxOpenSource.jar"

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
