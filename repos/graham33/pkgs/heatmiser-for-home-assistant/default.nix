{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, neohubapi
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "heatmiserneo";
  version = "1.5";
  format = "other";

  src = fetchFromGitHub {
    owner = "MindrustUK";
    repo = "heatmiser-for-home-assistant";
    rev = "69060a8b7a043cfd407d0221c8950f5815077326";
    sha256 = "sha256-2JUFmOswmBg1AvJRosmi91fRQwofz2hQWNuP2uAv6N4=";
  };

  propagatedBuildInputs = [
    neohubapi
  ];

  meta = with lib; {
    homepage = "https://github.com/MindrustUK/heatmiser-for-home-assistant";
    license = licenses.asl20;
    description = "Heatmiser Neo-Hub / Neostat / Neostat-e support for home-assistant.io";
    maintainers = with maintainers; [ graham33 ];
  };
}
