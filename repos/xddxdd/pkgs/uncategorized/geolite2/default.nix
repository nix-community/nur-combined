{
  fetchurl,
  lib,
  stdenv,
}:
let
  geolite2AsnSrc = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.09.22/GeoLite2-ASN.mmdb";
    hash = "sha256-ZBzOBGE6VfzrLXw+8nYRjVqnIas/WuqwHFKRiDVF5Cg=";
  };
  geolite2CitySrc = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.09.22/GeoLite2-City.mmdb";
    hash = "sha256-mkT8OiHwE6INMJgDiva41t5F2K4iOFyUzXcj7hoOAOU=";
  };
  geolite2CountrySrc = fetchurl {
    url = "https://github.com/P3TERX/GeoLite.mmdb/releases/download/2026.09.22/GeoLite2-Country.mmdb";
    hash = "sha256-fKZ1Owk6aUQaXpGF9JjuHnZ8JO9sCRVJTR9oCQzKAy0=";
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "geolite2";
  version = "2026.09.22";
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
