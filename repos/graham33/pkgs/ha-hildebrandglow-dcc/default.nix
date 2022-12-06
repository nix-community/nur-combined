{ lib
, fetchFromGitHub
, home-assistant
}:

with home-assistant.python.pkgs; buildHomeAssistantCustomComponent rec {
  pname = "ha-hildebrandglow-dcc";
  version = "0.6.0";
  format = "none";

  src = fetchFromGitHub {
    owner = "HandyHat";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-5beHCjxmhfH0XkHAnWroEIVuTMl2uetrBdlY7x8zq2o=";
  };

  propagatedBuildInputs = [
  ];

  installPhase = ''
    mkdir -p $out/custom_components
    cp -r custom_components/hildebrandglow_dcc $out/custom_components/
  '';

  meta = with lib; {
    homepage = "https://github.com/HandyHat/ha-hildebrandglow-dcc";
    license = licenses.mit;
    description = "HomeAssistant custom integration for Hildebrand Glow";
    maintainers = with maintainers; [ graham33 ];
  };
}
