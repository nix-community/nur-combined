{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, neohubapi
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "heatmiserneo";
  version = "0.0.1-pre0d4905c";
  format = "other";

  src = fetchFromGitHub {
    owner = "MindrustUK";
    repo = "heatmiser-for-home-assistant";
    rev = "0d4905c022fca39c3b8134ece7246e3fabc00a84";
    sha256 = "sha256-nrpAvPyo4OFJcGdZKshaAxXmk6LvyOnJv99XEejXCh4=";
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
