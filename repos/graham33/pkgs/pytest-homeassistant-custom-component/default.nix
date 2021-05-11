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
  # 0.3.2 was built against homeassistant 2021.5.0b4
  version = "0.3.2";
  disabled = !isPy3k || isPy37;

  src = fetchFromGitHub {
    owner = "MatthewFlamm";
    repo = pname;
    rev = version;
    sha256 = "02yz1rl65v1vw6lxq750s58wvipnh6wg46cghfh21n0fwg9a6v71";
  };
  postPatch = ''
    substituteInPlace requirements_test.txt \
      --replace "coverage==5.5" "coverage>=5.3" \
      --replace "homeassistant==2021.5.0b4" "homeassistant>=2021.5.0,<2021.6" \
      --replace "jsonpickle==1.4.1" "jsonpickle>=1.4.1" \
      --replace "pipdeptree==1.0.0" "" \
      --replace "pylint-strict-informational==0.1" "" \
      --replace "pytest-cov==2.10.1" "pytest-cov>=2.10.1" \
      --replace "pytest-test-groups==1.0.3" "" \
      --replace "pytest-xdist==2.1.0" "pytest-xdist>=2.1.0" \
      --replace "responses==0.12.0" "responses>=0.12.0" \
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
