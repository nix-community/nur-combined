{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, fnv-hash-fast
, fnvhash
, home-assistant
, mock
, psutil-home-assistant
, pytest
, pytest-asyncio
, pytest-socket
, sqlalchemy
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "octopus-energy";
  version = "8.5.2";
  format = "other";

  src = fetchFromGitHub {
    owner = "BottlecapDave";
    repo = "HomeAssistant-OctopusEnergy";
    rev = "v${version}";
    sha256 = "sha256-hjTnmftqP+hpolE1yypL72vyx/ohuvvgVRAxC4dSfPc=";
  };

  checkInputs = [
    fnv-hash-fast
    fnvhash
    home-assistant
    mock
    psutil-home-assistant
    pytest
    pytest-socket
    pytest-asyncio
    sqlalchemy
  ];

  checkPhase = ''
    python -m pytest tests/unit
  '';

  meta = with lib; {
    homepage = "https://github.com/BottlecapDave/HomeAssistant-OctopusEnergy";
    license = licenses.mit;
    description = "Custom component to bring your Octopus Energy details into Home Assistant";
    maintainers = with maintainers; [ graham33 ];
  };
}
