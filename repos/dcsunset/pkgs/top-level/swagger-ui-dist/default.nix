{ lib, stdenv, fetchurl }:

stdenv.mkDerivation rec {
  pname = "swagger-ui-dist";
  version = "5.18.2";

  src = fetchurl {
    url = "https://registry.npmjs.org/swagger-ui-dist/-/swagger-ui-dist-${version}.tgz";
    hash = "sha256-jIcDG/1IO44Ng1+vDQnYJGRkKsQdZ0/8pE78Ir0KnCQ=";
  };

  installPhase = ''
    mkdir -p $out
    tar -xvf $src --strip-components 1 -C $out
  '';

  meta = with lib; {
    description = "collection of HTML, JavaScript, and CSS assets that dynamically generate beautiful documentation from a Swagger-compliant API";
    homepage = "https://www.npmjs.com/package/swagger-ui-dist";
    license = licenses.asl20;
  };
}

