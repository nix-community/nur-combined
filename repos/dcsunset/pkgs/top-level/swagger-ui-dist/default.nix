{ stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "swagger-ui-dist";
  version = "5.16.0";

  src = fetchurl {
    url = "https://registry.npmjs.org/swagger-ui-dist/-/swagger-ui-dist-${version}.tgz";
    hash = "sha256-3hRrm8AQViw3n/oS+ICgWW1K+QaE0R+UToba4H7XtyY=";
  };

  installPhase = ''
    mkdir -p $out/share
    cd $out/share
    tar -xvf $src
    mv package ${pname}
  '';
}

