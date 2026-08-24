{
  fetchurl,
  lib,
  stdenv,
}:
let
  sources = builtins.fromJSON (builtins.readFile ./sources.json);
in
stdenv.mkDerivation (finalAttrs: {
  pname = "dbip-lite";
  version = sources.dbip-country-lite.version;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    zcat ${fetchurl { inherit (sources.dbip-asn-lite) url hash; }} > $out/dbip-asn-lite.mmdb
    zcat ${fetchurl { inherit (sources.dbip-city-lite) url hash; }} > $out/dbip-city-lite.mmdb
    zcat ${fetchurl { inherit (sources.dbip-country-lite) url hash; }} > $out/dbip-country-lite.mmdb

    runHook postInstall
  '';

  passthru.updateScript = [ (toString ./update.sh) ];

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "DBIP's Lite GeoIP Country, City, and ASN databases";
    homepage = "https://db-ip.com/db/lite.php";
    license = lib.licenses.cc-by-sa-40;
  };
})
