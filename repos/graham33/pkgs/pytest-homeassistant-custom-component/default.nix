{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy37
, isPy3k
, coverage
, fnvhash
, homeassistant
, jsonpickle
, lru-dict
, mock-open
, numpy
, pipdeptree
, pytest
, pytest-aiohttp
, pytest-cov
, pytest-freezer
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
, tqdm
}:

buildPythonPackage rec {
  pname = "pytest-homeassistant-custom-component";
  version = "0.12.45";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "0pyx54473r4fra9428bzr0php8c0wyhh1c4x00l9378nrg259wbv";
  };

  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==7.0.0" "coverage>=6.4.4" \
      --replace "numpy==1.23.2" "numpy>=1.23.2" \
      --replace "pipdeptree==2.3.1" "pipdeptree>=2.3.1" \
      --replace "pytest==7.2.0" "pytest>=7.1.3" \
      --replace "pytest-asyncio==0.20.2" "pytest-asyncio>=0.19.0" \
      --replace "pytest-sugar==0.9.5" "pytest-sugar>=0.9.4" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-timeout==2.1.0" "pytest-timeout>=2.0.2" \
      --replace "respx==0.20.1" "respx>=0.20.0" \
      --replace "sqlalchemy==1.4.44" "sqlalchemy>=1.4.41" \
      --replace "stdlib-list==0.7.0" "" \
      --replace "tqdm==4.64.0" "tqdm>=4.64.0"
  '';

  propagatedBuildInputs = [
    fnvhash
    homeassistant
    lru-dict
    numpy
    pipdeptree
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
    pytest-freezer
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
