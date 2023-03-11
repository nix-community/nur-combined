{
  lib,
  python3,
  fetchPypi,
}:
python3.pkgs.buildPythonPackage rec {
  pname = "lorem";
  version = "0.1.1";

  format = "setuptools";

  src = fetchPypi {
    inherit pname version;
    hash = "sha256-eF9BCaJB/CiR5ZcF6F0GX25tPtatkXUKjLVNTz5Z2TQ=";
  };

  pythonImportsCheck = [
    "lorem"
  ];

  meta = with lib; {
    description = "Generator for random text that looks like Latin";
    homepage = "https://pypi.org/project/lorem/";
    license = licenses.mit;
  };
}
