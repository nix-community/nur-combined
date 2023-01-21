{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "hassio-ecoflow";
  version = "2.2.3";
  format = "other";

  src = fetchFromGitHub {
    owner = "vwt12eh8";
    repo = pname;
    rev = version;
    sha256 = "sha256-uHpstbq7obSYc9KMN8nGiYrLKB0BCjeONlIx4/EgmxI=";
  };

  propagatedBuildInputs = [
    reactivex
  ];

  installPhase = ''
    mkdir -p $out
    cp -r custom_components $out/
  '';

  meta = with lib; {
    homepage = "https://github.com/vwt12eh8/hassio-ecoflow";
    license = licenses.mit;
    description = "EcoFlow Portable Power Station Integration for Home Assistant";
    maintainers = with maintainers; [ graham33 ];
  };
}
