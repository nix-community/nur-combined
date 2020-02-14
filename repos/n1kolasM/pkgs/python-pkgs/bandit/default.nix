{ stdenv, buildPythonPackage, fetchPypi, GitPython
, pyyaml, six, stevedore, colorama }:
buildPythonPackage rec {
  pname = "bandit";
  version = "1.6.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0rb034c99pyhb4a60z7f2kz40cjydhm8m9v2blaal1rmhlam7rs1";
  };

  propagatedBuildInputs = [ GitPython pyyaml six stevedore colorama ];

  # Tests require python packages missing in nixpkgs: hacking, stestr
  doCheck = false;
  
  meta = with stdenv.lib; {
    description = "Security oriented static analyser for python code";
    homepage = https://pypi.org/project/bandit;
    license = licenses.asl20;
    maintainers = with lib.maintainers; [ ];
  };
}

