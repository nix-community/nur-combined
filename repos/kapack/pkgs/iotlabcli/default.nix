{ python3Packages }:

python3Packages.buildPythonPackage rec {
  pname = "iotlabcli";
  version = "3.3.0";
  src = python3Packages.fetchPypi {
    inherit pname version;
    sha256 = "sha256-5IHWTzaRrc9WSLFDWyA7VDkisYoV9ITRpirjbSLPf34=";
  };
  doCheck = false;
  propagatedBuildInputs = [
    python3Packages.requests
    python3Packages.jmespath
  ];
}
