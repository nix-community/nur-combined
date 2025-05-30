{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "d3";
  version = "7.9.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/d3/-/d3-${version}.tgz";
    hash = "sha256-fjZgVxCiulSEZ5fIxtiIkRNBshWuUyV9wypJoLgkNV4=";
  };

  installPhase = ''
    mkdir -p $out
    tar -xvf $src --strip-components 1 -C $out
  '';

  meta = with lib; {
    description = "Bring data to life with SVG, Canvas and HTML";
    homepage = "https://www.npmjs.com/package/d3";
    license = licenses.isc;
  };
}

