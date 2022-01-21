{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "hass-smartbox";
  version = "0.10.2-pre+ced590";
  format = "other";

  src = fetchFromGitHub {
    owner = "graham33";
    repo = pname;
    rev = "ced59040ba3bda37a354f8dc29b35080be601333";
    sha256 = "04vc5sdwjy968y8n809rjgjbd2jn6a5j8l94fw29mhvya5vfzysl";
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
