{ lib
, buildPythonPackage
, fetchPypi
, quart
, pythonOlder
, pytest
, pytest-asyncio
}:

buildPythonPackage rec {
  pname = "quart-cors";
  version = "0.3.0";

  disabled = pythonOlder "3.7"; # requires python version >=3.7.0

  src = fetchPypi {
    pname = "Quart-CORS";
    inherit version;
    sha256 = "c08bdb326219b6c186d19ed6a97a7fd02de8fe36c7856af889494c69b525c53c";
  };

  propagatedBuildInputs = [
    quart
  ];

  checkInputs = [
    pytest
    pytest-asyncio
  ];

  meta = with lib; {
    description = "A Quart extension to provide Cross Origin Resource Sharing, access control, support";
    homepage = https://gitlab.com/pgjones/quart-cors/;
    license = licenses.mit;
    # maintainers = [ maintainers. ];
  };
}
