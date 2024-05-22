{
  stdenv,
  sources,
  lib,
  ...
}:
stdenv.mkDerivation rec {
  inherit (sources.route-chain) pname version src;
  enableParallelBuilding = true;
  installPhase = ''
    make install PREFIX=$out
  '';

  meta = with lib; {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "A small app to generate a long path in traceroute.";
    homepage = "https://github.com/xddxdd/route-chain";
    license = licenses.unlicense;
  };
}
