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
    description = "Yet Another Clash Dashboard";
    homepage = "https://github.com/haishanh/yacd";
    license = licenses.mit;
  };
}
