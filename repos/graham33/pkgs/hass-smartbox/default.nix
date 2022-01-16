{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "hass-smartbox";
  version = "0.10.0-pre+79b104";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "79b104f9022fbc5567a31f0918dd376c15ff4ff4";
    sha256 = "0ab5ws2yz9lvf7lxnq3l5cbdkyicacymd89swfjp90zgxjr5awli";
  };

  propagatedBuildInputs = [
    smartbox
    voluptuous
  ];

  checkInputs = [
    homeassistant
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
