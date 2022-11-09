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
  version = "0.12.18";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "sha256-+6sPME4anNLixGHNEEMCD7wJKq+m/TfFE72xLw8RA0U=";
  };

  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==6.4.4" "coverage>=6.4.2" \
      --replace "freezegun==1.2.1" "jsonpickle>=1.1.0" \
      --replace "numpy==1.23.2" "numpy>=1.23.2" \
      --replace "pipdeptree==2.3.1" "pipdeptree>=2.3.1" \
      --replace "pytest==7.1.2" "pytest>=7.1.1" \
      --replace "pytest-sugar==0.9.5" "pytest-sugar>=0.9.4" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-timeout==2.1.0" "pytest-timeout>=2.0.2" \
      --replace "requests_mock==1.9.2" "requests_mock>=1.9.2" \
      --replace "sqlalchemy==1.4.40" "sqlalchemy>=1.4.40" \
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
    maintainers = with maintainers; [ graham33 ];
  };
}
