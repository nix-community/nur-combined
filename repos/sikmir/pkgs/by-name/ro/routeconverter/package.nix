{
  lib,
  stdenv,
  fetchfromgh,
  jre,
  makeWrapper,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "routeconverter";
  version = "3.5";

  __structuredAttrs = true;

  srcs = [
    (fetchfromgh {
      owner = "cpesch";
      repo = "RouteConverter";
      tag = finalAttrs.version;
      hash = "sha256-Cip/rkPT2OfVRQYNtZtl5WhtlIVVeun3+EIXj10NkMQ=";
      name = "RouteConverterLinux.jar";
    })
    (fetchfromgh {
      owner = "cpesch";
      repo = "RouteConverter";
      tag = finalAttrs.version;
      hash = "sha256-Yg9ZZUJ3THia8tJSerAPYl8VI9L6kcIFzX0xnH2q7w8=";
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
