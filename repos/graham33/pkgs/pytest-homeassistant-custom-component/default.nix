{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy37
, isPy3k
, coverage
, fnvhash
, freezegun
, home-assistant
, jsonpickle
, lru-dict
, mock-open
, numpy
, paho-mqtt
, pipdeptree
, pydantic
, pylint-per-file-ignores
, pytest
, pytest-aiohttp
, pytest-cov
, pytest-freezer
, pytest-picked
, pytest-socket
, pytest-sugar
, pytest-timeout
, pytest-unordered
, pytest-xdist
, pytestCheckHook
, requests-mock
, responses
, respx
, sqlalchemy
, syrupy
, tqdm
}:

buildPythonPackage rec {
  pname = "pytest-homeassistant-custom-component";
  version = "0.13.174";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "08mw7j3awrc91r8mxqyxjsw9kw808qsxddri8d3v36pnmv77mmb0";
  };

  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==7.2.7" "coverage>=7.2.1" \
      --replace "numpy==1.23.2" "numpy>=1.23.2" \
      --replace "pipdeptree==2.11.0" "pipdeptree>=2.11.0" \
      --replace "pydantic==1.10.11" "pydantic>=1.10.9" \
      --replace "pytest==7.3.1" "pytest>=7.2.1" \
      --replace "pytest-asyncio==0.21.0" "pytest-asyncio>=0.21.1" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-timeout==2.1.0" "pytest-timeout>=2.0.2" \
      --replace "respx==0.20.2" "respx>=0.20.1" \
      --replace "SQLAlchemy==2.0.15" "SQLAlchemy>=2.0.15" \
      --replace "tqdm==4.65.0" "tqdm>=4.64.1"
  '';

  propagatedBuildInputs = [
    fnvhash
    freezegun
    home-assistant
    lru-dict
    numpy
    paho-mqtt
    pipdeptree
    pylint-per-file-ignores
    pytest
    pytest-socket
    requests-mock
    sqlalchemy
    syrupy
  ];

  checkInputs = [
    coverage
    jsonpickle
    mock-open
    pydantic
    pytest-aiohttp
    pytest-cov
    pytest-freezer
    pytest-picked
    pytest-sugar
    pytest-timeout
    pytest-unordered
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
    maintainers = with maintainers; [ graham33 ];
  };
}
