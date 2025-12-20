{
  lib,
  stdenvNoCC,
  sources,
}:
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "maxmind-geolite2";
  inherit (sources.geolite2-asn) version;

  srcs = [
    sources.geolite2-asn.src
    sources.geolite2-city.src
    sources.geolite2-country.src
  ];

  dontConfigure = true;
  dontBuild = true;
  dontUnpack = true;

  installPhase = ''
    runHook preInstall

    install -Dm644 ${builtins.elemAt finalAttrs.srcs 0} $out/share/geolite2/asn.mmdb
    install -Dm644 ${builtins.elemAt finalAttrs.srcs 1} $out/share/geolite2/city.mmdb
    install -Dm644 ${builtins.elemAt finalAttrs.srcs 2} $out/share/geolite2/country.mmdb

    runHook postInstall
  '';

  meta = {
    description = "MaxMind's GeoIP2 GeoLite2 Country, City, and ASN databases";
    homepage = "https://github.com/P3TERX/GeoLite.mmdb";
    license = lib.licenses.unfree;
  };
})
