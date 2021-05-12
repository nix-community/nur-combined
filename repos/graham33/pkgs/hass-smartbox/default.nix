{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, smartbox
, pytest-aiohttp
, pytest-asyncio
, pytest-cov
, pytest-homeassistant-custom-component
, pytest-randomly
, pytest-sugar
, pytestCheckHook
, haManifestRequirementsCheckHook
}:

buildPythonPackage rec {
  pname = "hass-smartbox";
  version = "0.2.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "f4989219685a06d2e4be3e2ba0e19e18e8f95664";
    sha256 = "0087qdc9qdm2vz5c5sd3g86qkbjva1y910ydbls1969ryyvm5cx2";
  };

  propagatedBuildInputs = [
    smartbox
  ];

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/smartbox $out/custom_components/
  '';

  doCheck = true;

  checkInputs = [
    pytest-aiohttp
    pytest-asyncio
    pytest-cov
    pytest-homeassistant-custom-component
    pytest-randomly
    pytest-sugar
    pytestCheckHook
    haManifestRequirementsCheckHook
  ];

  meta = with lib; {
    homepage = "https://github.com/graham33/hass-smartbox";
    license = licenses.mit;
    description = "Home Assistant integration for heating smartboxes.";
    maintainers = with maintainers; [ graham33 ];
  };
}
