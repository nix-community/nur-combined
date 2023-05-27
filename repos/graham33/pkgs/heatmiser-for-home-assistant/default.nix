{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "heatmiser-for-home-assistant";
  version = "0.0.1-pre434b6eb";
  format = "other";

  src = fetchFromGitHub {
    owner = "MindrustUK";
    repo = pname;
    rev = "434b6eb92b0f76dd045bd222b8e4860d0492e6a9";
    sha256 = "sha256-9fD6rHzSI4IXEXNq/WcD/EXWRf0kE/rhckzOZrJ4xKw=";
  };

  propagatedBuildInputs = [
    neohubapi
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/MindrustUK/heatmiser-for-home-assistant";
    license = licenses.asl20;
    description = "Heatmiser Neo-Hub / Neostat / Neostat-e support for home-assistant.io";
    maintainers = with maintainers; [ graham33 ];
  };
}
