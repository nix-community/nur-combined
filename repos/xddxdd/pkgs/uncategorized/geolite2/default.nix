{
  fetchurl,
  lib,
  stdenv,
}:
let
  geolite2AsnSrc = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.09.07/GeoLite2-ASN.mmdb";
    hash = "sha256-gLipYtv8HtR5QRWw7cq7zojMj3H/KJP6MuriRHNw7vw=";
  };
  geolite2CitySrc = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.09.07/GeoLite2-City.mmdb";
    hash = "sha256-iS9xGhOaXHbdK3kI8IcUjHKd8oelBDNtqizMfiKS670=";
  };
  geolite2CountrySrc = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.09.07/GeoLite2-Country.mmdb";
    hash = "sha256-RHEjFLb4vrYptF+orXy78EpV41KpHnWooYOA1i4lhhY=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "geolite2";
  version = "2026.09.07";
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 ${geolite2AsnSrc} $out/GeoLite2-ASN.mmdb
    install -Dm755 ${geolite2CitySrc} $out/GeoLite2-City.mmdb
    install -Dm755 ${geolite2CountrySrc} $out/GeoLite2-Country.mmdb

    runHook postInstall
  '';

  passthru = {
    asn = geolite2AsnSrc;
    city = geolite2CitySrc;
    country = geolite2CountrySrc;
  };

  passthru.updateScript = [ (toString ./update.sh) ];
  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "MaxMind's GeoIP2 GeoLite2 Country, City, and ASN databases";
    homepage = "https://dev.maxmind.com/geoip/geoip2/geolite2/";
    license = lib.licenses.cc-by-sa-40;
  };
})
