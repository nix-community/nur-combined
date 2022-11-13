{ lib, stdenv, sources }:

stdenv.mkDerivation rec {
  inherit (sources.yacd) pname version src;

  installPhase = ''
    runHook preInstall
    mkdir -p $out
    cp -r ./ $out
    runHook postInstall
  '';

  meta = with lib; {
    description = "A GeoLite2 data created by MaxMind";
    homepage = "https://github.com/Dreamacro/maxmind-geoip";
    license = licenses.unfree;
    maintainers = with maintainers; [ candyc1oud ];
  };
}
