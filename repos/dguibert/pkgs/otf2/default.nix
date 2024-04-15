{
  stdenv,
  lib,
  fetchurl,
}:
stdenv.mkDerivation {
  pname = "otf2";
  version = "2.3";
  src = fetchurl {
    url = "https://zenodo.org/record/5883792/files/otf2-3.0.tar.gz?download=1";
    name = "otf2-3.0.tar.gz";
    sha256 = "sha256-b/8HKHYVVugFsUD9RkQCztOUo8Yi7e3bYYAl5s2qbYw=";
  };
  configureFlags = [
    #"--with-frontend-compiler-suite=(gcc|ibm|intel|pgi|studio)"
    "${lib.optionalString stdenv.cc.isIntel or false "--with-nocross-compiler-suite=intel"}"
  ];
}
