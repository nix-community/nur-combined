{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "ha-dyson";
  version = "0.16.4-4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-HLY8+eXzfVasO1EVZQ46mooJ4beID01RvYo4BfjHfnc=";
  };

  propagatedBuildInputs = [
    libdyson
    setuptools
  ];

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/dyson_local $out/custom_components/
  '';

  meta = with lib; {
    homepage = "https://github.com/shenxn/ha-dyson";
    license = licenses.mit;
    description = "HomeAssistant custom integration for Dyson";
    maintainers = with maintainers; [ graham33 ];
  };
}
