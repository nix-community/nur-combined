{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "octopus-energy";
  version = "8.4.4";
  format = "other";

  src = fetchFromGitHub {
    owner = "BottlecapDave";
    repo = "HomeAssistant-OctopusEnergy";
    rev = "v${version}";
    sha256 = "sha256-UeNhwQ5YuJCdRbgZKmorfFRDiJH5GdYznnSfGhHkbgU=";
  };

  propagatedBuildInputs = [
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  checkInputs = [
    home-assistant
    fnv-hash-fast
    mock
    psutil-home-assistant
    pytest
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
