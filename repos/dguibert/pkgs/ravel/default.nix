{
  stdenv,
  fetchFromGitHub,
  otf2,
  muster,
  openmpi,
  cmake,
  qt5,
  boost,
}:
stdenv.mkDerivation {
  pname = "ravel";
  version = "1.0.0";
  src = fetchFromGitHub {
    owner = "LLNL";
    repo = "ravel";
    rev = "67f0e95178074998e9eee53a53c9ae9084af6b2e";
    sha256 = "00f7k8w9akjjb6sz20ajgc7blcan2kamdliaac56p36yx6krxl0i";
  };
  buildInputs = [otf2 muster openmpi cmake qt5.qtbase boost];
}
