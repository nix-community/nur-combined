{ lib, stdenv, fetchurl, jre, makeWrapper }:

stdenv.mkDerivation (finalAttrs: {
  pname = "routeconverter";
  version = "2.33";

  srcs = [
    (fetchurl {
      url = "https://static.routeconverter.com/download/previous-releases/${finalAttrs.version}/RouteConverterLinuxOpenSource.jar";
      hash = "sha256-GDvrn5YfLej+v5vJ9bRP2M4g6bESpl43rFsR39mRpRI=";
    })
    (fetchurl {
      url = "https://static.routeconverter.com/download/previous-releases/${finalAttrs.version}/RouteConverterCmdLine.jar";
      hash = "sha256-pTA8/1zDwYMB02tkKGDTiTdyhVJwIl3sTkdiUAEwWZs=";
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

  meta = with lib; {
    description = "A free tool to edit and convert routes, tracks and waypoints";
    homepage = "https://www.routeconverter.com/";
    sourceProvenance = with sourceTypes; [ binaryBytecode ];
    license = licenses.gpl2Plus;
    maintainers = [ maintainers.sikmir ];
    platforms = jre.meta.platforms;
  };
})
