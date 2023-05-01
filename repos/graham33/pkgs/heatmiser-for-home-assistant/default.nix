{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "heatmiser-for-home-assistant";
  version = "0.0.1-pre";
  format = "other";

  src = fetchFromGitHub {
    owner = "MindrustUK";
    repo = pname;
    rev = "1f76811f3363f8d2d80f91b79b52cf075044f32c";
    sha256 = "sha256-kSHDNAq139WqNk4U4P6WFwHAOE3NTrK4Fl1sxDWNluI=";
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
