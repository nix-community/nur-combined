{ lib
, buildPythonPackage
, python
, fetchFromGitHub
, homeassistant
, smartbox
, voluptuous
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
  version = "0.7.0-pre71cddb4";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    #rev = "v${version}";
    rev = "71cddb4de08e736596dd919658bccf230b6ffb83";
    sha256 = "sha256-WSFyDd7e4bzTrjlkVLVfocVBetjFHmPKWF0gzTbN2Q8=";
  };

  propagatedBuildInputs = [
    homeassistant
    smartbox
    voluptuous
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
