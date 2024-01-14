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
  version = "2.0.0-pre+c02086";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = "hass-smartbox";
    rev = "c0208634c8c63dbab064573f2bb570e7cfd484c1";
    sha256 = "100wj7chg3i89p67mrc2y9i029b4cwhhdzfnigdlh2ar9h4xx67p";
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
