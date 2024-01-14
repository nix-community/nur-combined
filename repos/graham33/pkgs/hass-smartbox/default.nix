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
  version = "2.0.0-beta.2";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = "hass-smartbox";
    rev = "v${version}";
    sha256 = "12dhgga5az45002ixzlm0kr1sl9cy38wd2x53xk6vaij21vmxzd4";
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

  doCheck = false;

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/smartbox $out/custom_components/
  '';

  # TODO: remove once fixed
  disabledTests = [
    "test_setup_missing_and_extra_devices"
    "test_setup_multiple_accounts_and_devices"
    "test_setup_unsupported_nodes"
  ];

  meta = with lib; {
    homepage = "https://github.com/graham33/hass-smartbox";
    license = licenses.mit;
    description = "Home Assistant integration for heating smartboxes.";
    maintainers = with maintainers; [ graham33 ];
  };
}
