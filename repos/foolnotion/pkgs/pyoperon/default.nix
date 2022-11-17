{ lib, buildPythonPackage, fetchPypi }:
buildPythonPackage rec {
  pname = "pyoperon";
  version = "0.3.3";
  format = "wheel";

  src = fetchPypi {
    inherit pname version format;
    dist = "cp310";
    abi = "cp310";
    python = "cp310";
    platform = "manylinux_2_27_x86_64";
    sha256 = "sha256-uzC5sWEVENskjUcrDWJTLTpEzLGeLlXdMVrC9y9vAO8=";
  };

  doCheck = false;

  meta = with lib; {
    homepage = "https://github.com/heal-research/pyoperon";
    description = "";
    license = licenses.mit;
    #maintainers = with maintainers; [ fridh ];
  };
}
