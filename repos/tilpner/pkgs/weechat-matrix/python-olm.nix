{ buildPythonPackage, fetchFromGitHub,
  olm, cffi, future, typing }:

buildPythonPackage {
  pname = "python-olm";
  version = "dev";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "python-olm";
    rev = "6ce1ffe6a7b3473959040405ae076dab21c8acc4";
    sha256 = "1d64asb2h909wskwclmalbswwij6qbhr966lxa2ihx4ccd1z0x9m";
  };

  buildInputs = [ olm ];

  propagatedBuildInputs = [
    cffi
    future
    typing
  ];
}
