{
  sources,
  lib,
  stdenv,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "geolite2";
  inherit (sources.geolite2-asn) version;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${sources.geolite2-asn.src} $out/GeoLite2-ASN.mmdb
    install -Dm755 ${sources.geolite2-city.src} $out/GeoLite2-City.mmdb
    install -Dm755 ${sources.geolite2-country.src} $out/GeoLite2-Country.mmdb

    runHook postInstall
  '';

  passthru = {
    asn = sources.geolite2-asn.src;
    city = sources.geolite2-city.src;
    country = sources.geolite2-country.src;
  };

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MaxMind's GeoIP2 GeoLite2 Country, City, and ASN databases";
    homepage = "https://dev.maxmind.com/geoip/geoip2/geolite2/";
    license = lib.licenses.cc-by-sa-40;
  };
})
