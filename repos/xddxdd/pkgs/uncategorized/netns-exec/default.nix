{ stdenv
, sources
, lib
, ...
} @ args:

stdenv.mkDerivation rec {
  inherit (sources.netns-exec) pname version src;
  buildPhase = ''
    substituteInPlace Makefile --replace "-m4755" "-m755"
  '';
  installPhase = ''
    mkdir -p $out
    make install PREFIX=$out
  '';

  meta = with lib; {
    description = "Run command in Linux network namespace as normal user";
    homepage = "https://github.com/pekman/netns-exec";
    license = licenses.gpl2;
  };
}
