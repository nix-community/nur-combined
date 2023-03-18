{
  lib,
  python3Packages,
}:
python3Packages.buildPythonPackage rec {
  pname = "uuid6";
  version = "2022.10.25";

  format = "setuptools";

  src = python3Packages.fetchPypi {
    inherit pname version;
    hash = "sha256-ClaTXenBzo3YVZIluEVUnZSRfZ4krUscwjKO6lvgAQw=";
  };

  pythonImportsCheck = [
    "uuid6"
  ];

  meta = with lib; {
    description = "New time-based UUID formats which are suited for use as a database key";
    homepage = "https://pypi.org/project/uuid6/";
    license = licenses.mit;
  };
}
