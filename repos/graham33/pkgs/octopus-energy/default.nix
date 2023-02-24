{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "octopus-energy";
  version = "5.4.1";
  format = "other";

  src = fetchFromGitHub {
    owner = "BottlecapDave";
    repo = "HomeAssistant-OctopusEnergy";
    rev = "v${version}";
    sha256 = "sha256-A/k0ZTTYZ6MHb8h9Wlv+tiBKUj9X1Jcl81+GX/RSRkc=";
  };

  propagatedBuildInputs = [
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  checkInputs = [
    home-assistant
    mock
    pytest
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
