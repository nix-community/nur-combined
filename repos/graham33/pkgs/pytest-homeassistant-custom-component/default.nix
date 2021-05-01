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
  # 0.3.1 was built against homeassistant 2021.4.4
  version = "0.3.1";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "1ch62zmm7dwbncinmdncvcjm22dqqx8lk0j2kw3dcnl4fx07311g";
  };
  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==5.5" "coverage>=5.3" \
      --replace "homeassistant==2021.4.4" "homeassistant>=2021.4.4,<2021.5" \
      --replace "jsonpickle==1.4.1" "jsonpickle>=1.4.1" \
      --replace "pipdeptree==1.0.0" "" \
      --replace "pylint-strict-informational==0.1" "" \
      --replace "pytest==6.2.2" "pytest>=6.1.2" \
      --replace "pytest-cov==2.10.1" "pytest-cov>=2.10.1" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-xdist==2.1.0" "pytest-xdist>=2.1.0" \
      --replace "responses==0.12.0" "responses>=0.12.0" \
      --replace "respx==0.16.2" "respx>=0.16.2" \
      --replace "stdlib-list==0.7.0" "" \
      --replace "tqdm==4.49.0" "tqdm>=4.49.0"
  '';

  propagatedBuildInputs = [
    homeassistant
    pytest
    requests-mock
    sqlalchemy
  ];

  checkInputs = [
    coverage
    jsonpickle
    mock-open
    pytest-aiohttp
    pytest-cov
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
