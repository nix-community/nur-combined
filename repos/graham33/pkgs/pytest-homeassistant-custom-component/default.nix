{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy37
, isPy3k
, coverage
, homeassistant
, jsonpickle
, mock-open
, pytest
, pytest-aiohttp
, pytest-cov
, pytest-freezegun
, pytest-socket
, pytest-sugar
, pytest-timeout
, pytest-xdist
, pytestCheckHook
, requests-mock
, responses
, respx
, sqlalchemy
, tqdm
}:

buildPythonPackage rec {
  pname = "pytest-homeassistant-custom-component";
  version = "0.5.10";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "0nndgwxl238vdavhzkfkg4xlf6a8h4b8lknxxmf8xwgzj0bcyvlv";
  };

  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==6.2.0" "coverage>=5.5" \
      --replace "homeassistant==2021.11.0b0" "homeassistant>=2021.11.0,<2021.12" \
      --replace "jsonpickle==1.4.1" "jsonpickle>=1.4.1" \
      --replace "pipdeptree==2.2.0" "" \
      --replace "pylint-strict-informational==0.1" "" \
      --replace "pytest-socket==0.4.1" "pytest-socket>=0.4.0" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-timeout==2.0.1" "pytest-timeout>=1.4.2" \
      --replace "pytest-xdist==2.4.0" "pytest-xdist>=2.3.0" \
      --replace "requests_mock==1.9.2" "requests_mock>=1.9.2" \
      --replace "respx==0.17.0" "respx>=0.17.0" \
      --replace "responses==0.12.0" "responses>=0.12.0" \
      --replace "sqlalchemy==1.4.23" "sqlalchemy>=1.4.23" \
      --replace "stdlib-list==0.7.0" "" \
      --replace "tqdm==4.49.0" "tqdm>=4.49.0"
  '';

  propagatedBuildInputs = [
    homeassistant
    pytest
    pytest-socket
    requests-mock
    sqlalchemy
  ];

  checkInputs = [
    coverage
    jsonpickle
    mock-open
    pytest-aiohttp
    pytest-cov
    pytest-freezegun
    pytest-sugar
    pytest-timeout
    pytest-xdist
    pytestCheckHook
    responses
    respx
    tqdm
  ];

  pythonImportsCheck = [ "pytest_homeassistant_custom_component" ];

  meta = with lib; {
    homepage = "https://github.com/MatthewFlamm/pytest-homeassistant-custom-component";
    description = "Package to automatically extract testing plugins from Home Assistant for custom component testing. ";
    license = licenses.mit;
    #maintainers = with maintainers; [ graham33 ];
  };
}
