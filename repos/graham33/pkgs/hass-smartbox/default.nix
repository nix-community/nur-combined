{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, home-assistant
, homeassistant-stubs
, mypy
, pytest-aiohttp
, pytest-asyncio
, pytest-cov
, pytest-homeassistant-custom-component
, pytest-randomly
, pytest-sugar
, pytestCheckHook
, smartbox
, voluptuous
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "smartbox";
  version = "0.0.1-pre+a5b1e8";
  format = "other";

  src = fetchFromGitHub {
    owner = "davefrooney";
    repo = "hass-smartbox";
    rev = "a5b1e849aa622bbd4bb0f9bf9e78ef50b561f208";
    sha256 = "0c7jvhmqncanw2zrgs1f6cwmzbsg2b05b7knxsva373jbmvkw27p";
  };

  propagatedBuildInputs = [
    smartbox
    voluptuous
  ];

  checkInputs = [
    home-assistant
    homeassistant-stubs
    mypy
    pytest-aiohttp
    pytest-asyncio
    pytest-cov
    pytest-homeassistant-custom-component
    pytest-randomly
    pytest-sugar
    pytestCheckHook
  ];

  # TODO
  doCheck = false;

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/smartbox $out/custom_components/
  '';

  meta = with lib; {
    homepage = "https://github.com/graham33/hass-smartbox";
    license = licenses.mit;
    description = "Home Assistant integration for heating smartboxes.";
    maintainers = with maintainers; [ graham33 ];
  };
}
