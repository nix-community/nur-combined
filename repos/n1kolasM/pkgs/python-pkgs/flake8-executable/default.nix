{ lib, buildPythonPackage, fetchPypi
, flake8 }:
buildPythonPackage rec {
  pname = "flake8-executable";
  version = "2.0.3";

  src = fetchPypi {
    inherit pname version;
    sha256 = "0vg1yyz2ff4ghkmyfvm84wp0zspnnafm0k8wbljb2qsbn5wgydm6";
  };

  propagatedBuildInputs = [ flake8 ];
  
  meta = with lib; {
    description = "A Flake8 plugin for checking executable permissions and shebangs.";
    homepage = https://pypi.org/project/flake8-executable;
    license = licenses.lgpl3Plus;
  };
}

