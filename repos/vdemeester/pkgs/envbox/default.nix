{ stdenv, lib, buildGoPackage, fetchFromGitHub }:

buildGoPackage rec {
  name = "envbox-${version}";
  version = "0.2.0";
  rev = "v${version}";

  goPackagePath = "github.com/justone/envbox";

  src = fetchFromGitHub {
    inherit rev;
    owner = "justone";
    repo = "envbox";
    sha256 = "0jryr7czaqdhqq4w7mjmhbpplfflg4b0hgfgyn8jn5l2sd63k70i";
  };

  meta = {
    description = "Secure environment variables via secretbox";
    homepage = "https://github.com/justone/envbox";
    license = lib.licenses.mit;
  };
}
