{ lib
, buildPythonPackage
, fetchFromGitHub
, isPy37
, isPy3k
, coverage
, fnvhash
, freezegun
, homeassistant
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
  version = "0.13.32";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "1xcpprl5rhdmbfwz2m8pqmlw0d4g03m01ybng026rwwd7azgr26h";
  };

  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==7.2.3" "coverage>=7.2.1" \
      --replace "numpy==1.23.2" "numpy>=1.23.2" \
      --replace "pipdeptree==2.7.0" "pipdeptree>=2.7.0" \
      --replace "pydantic==1.10.7" "pydantic>=1.10.5" \
      --replace "pylint-per-file-ignores==1.1.0" "pylint-per-file-ignores>=1.1.0" \
      --replace "pytest==7.3.1" "pytest>=7.2.1" \
      --replace "pytest-cov==3.0.0" "pytest-cov>=3.0.0" \
      --replace "pytest-socket==0.5.1" "pytest-socket>=0.5.1" \
      --replace "pytest-sugar==0.9.6" "pytest-sugar>=0.9.6" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-timeout==2.1.0" "pytest-timeout>=2.0.2" \
      --replace "respx==0.20.1" "respx>=0.20.0" \
      --replace "syrupy==4.0.0" "syrupy>=4.0.0" \
      --replace "tqdm==4.64.0" "tqdm>=4.64.0"
  '';

  propagatedBuildInputs = [
    fnvhash
    freezegun
    homeassistant
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
