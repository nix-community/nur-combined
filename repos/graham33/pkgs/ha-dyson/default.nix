{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "ha-dyson";
  version = "0.16.2";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = pname;
    rev = "v${version}";
    sha256 = "1fx1q57a5pr7rxmxszax6icp3ramflmqj80fhwyyjwhwjm4z7szl";
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
