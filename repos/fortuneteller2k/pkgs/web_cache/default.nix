{ lib, python38Packages }:

with python38Packages;

buildPythonPackage rec {
  pname = "web_cache";
  version = "1.1.0";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-1aEKNMh77/x5S44d7He/a0GYhrnMYLmxDHBoEIcODrU=";
  };

  doCheck = false;

  meta = with lib; {
    description = "Simple Python key-value storage backed up by sqlite3 database";
    homepage = "https://github.com/desbma/web_cache";
    license = licenses.mit;
    maintainers = with maintainers; [ fortuneteller2k ];
  };
}
