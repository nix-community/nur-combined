{ stdenv
, python3
, python3Packages
, fetchgit
, cliapp
, ttystatus
}:

python3.pkgs.buildPythonPackage rec {
  pname = "cmdtest";
  version = "0.32.14.git";

  src = fetchgit {
    url = "git://git.liw.fi/cmdtest/";
    rev = "cdfe14e451347fde4c9a2b0d2f8077136559cdba";
    sha256 = "1yhcwsqcpckkq5kw3h07k0xg6infyiyzq9ni3nqphrzxis7hxjf1";
  };

  propagatedBuildInputs = with python3Packages; [ cliapp ttystatus markdown ];

  # TODO: cmdtest tests must be run before the buildPhase
  doCheck = false;

  meta = with stdenv.lib; {
    homepage = http://liw.fi/cmdtest/;
    description = "Black box tests Unix command line tools";
    license = licenses.gpl3;
  };

}
