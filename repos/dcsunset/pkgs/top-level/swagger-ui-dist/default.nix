{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "swagger-ui-dist";
  version = "5.17.14";

  src = fetchurl {
    url = "https://registry.npmjs.org/swagger-ui-dist/-/swagger-ui-dist-${version}.tgz";
    hash = "sha256-xXut9FmqbmXMA2s4YtBQKmP5oiVGQH/8sOZPhfgWuyg=";
  };

  installPhase = ''
    mkdir -p $out/share
    cd $out/share
    tar -xvf $src
    mv package ${pname}
  '';

  meta = with lib; {
    description = "collection of HTML, JavaScript, and CSS assets that dynamically generate beautiful documentation from a Swagger-compliant API";
    homepage = "https://www.npmjs.com/package/swagger-ui-dist";
    license = licenses.asl20;
  };
}

