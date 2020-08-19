{ stdenv, fetchFromGitHub, lib }:

stdenv.mkDerivation rec {
  pname = "shlide";
  version = "v0.1.0";

  src = fetchFromGitHub {
    owner = "icyphox";
    repo = "shlide";
    rev = version;
    sha256 = "187mvkjwf1cmzhxb1c28pzp7jrkyvays1d5c9xgbv6ms97a58rzm";
  };

  dontBuild = true;

  makeFlags = [
    "PREFIX=${placeholder "out"}"
  ];

  meta = with lib; {
    description = "slide deck presentation tool written in pure bash";
    homepage = "https://github.com/icyphox/shlide";
    license = licenses.mit;
  };
}

