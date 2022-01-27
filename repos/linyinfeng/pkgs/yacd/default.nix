{ sources, lib, stdenv }:

stdenv.mkDerivation rec {
  inherit (sources.yacd) pname version src;

  installPhase = ''
    cp -r . $out
  '';

  meta = with lib; {
    homepage = "https://github.com/haishanh/yacd";
    description = "Yet Another Clash Dashboard";
    license = licenses.mit;
  };
}
