{ lib
, buildPythonPackage
, fetchPypi
, async-property
, websockets
}:

buildPythonPackage rec {
  pname = "neohubapi";
  version = "2.2";

  src = fetchPypi {
    inherit pname version;
    sha256 = "sha256-2MputN0iJ7fEt9ZsAmplv5beURpBeZYB4JL/u7SDMTc=";
  };

  propagatedBuildInputs = [
    async-property
    websockets
  ];

  checkInputs = [
  ];

  pythonImportsCheck = [ "neohubapi" ];

  meta = with lib; {
    homepage = "https://gitlab.com/neohubapi/neohubapi";
    description = "Async library to communicate with Heatmiser NeoHub 2 API";
    license = licenses.mit;
    maintainers = with maintainers; [ graham33 ];
  };
}
