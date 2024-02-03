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
  version = "2.0.0-pre+500fbd";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = "hass-smartbox";
    rev = "500fbd50e832d7245e093493aba840217a40b0aa";
    sha256 = "07nyfgxracn7rmhk5xr3xhwk99c4q096ww0nc6y9vp6a2xi2m7vq";
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
