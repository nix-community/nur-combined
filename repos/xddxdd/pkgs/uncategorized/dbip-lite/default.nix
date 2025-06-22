{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "dbip-lite";
  inherit (sources.dbip-asn-lite) version;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    zcat ${sources.dbip-asn-lite.src} > $out/dbip-asn-lite.mmdb
    zcat ${sources.dbip-city-lite.src} > $out/dbip-city-lite.mmdb
    zcat ${sources.dbip-country-lite.src} > $out/dbip-country-lite.mmdb

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "DBIP's Lite GeoIP Country, City, and ASN databases";
    homepage = "https://db-ip.com/db/lite.php";
    license = lib.licenses.cc-by-sa-40;
  };
})
