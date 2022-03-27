{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "hass-smartbox";
  version = "1.1.0-pre+415bdd";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "415bdd9f8b06450e61a8c3ee5c4c67fe97b69fc1";
    sha256 = "0vnaw0b4vl7i3wphjp6qlp6p8dy8rbpzhcpvvzqcfp0vh4z4f0is";
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
