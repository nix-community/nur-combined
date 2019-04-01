{ buildPythonPackage, fetchFromGitHub,
  olm, cffi, future, typing }:

buildPythonPackage {
  pname = "python-olm";
  version = "git";

  src = fetchFromGitHub {
    owner = "poljar";
    repo = "python-olm";
    rev = "2594bbc87ec37cf743d427777748bb333be3e89d";
    sha256 = "0s728ydbhwjrhz03b3iwqbmi31fs1rri86vphv64pkysigydidh2";
  };

  buildInputs = [ olm ];

  propagatedBuildInputs = [
    cffi
    future
    typing
  ];
}
