{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "solis";
  version = "3.5.0";
  format = "other";

  src = fetchFromGitHub {
    owner = "hultenvp";
    repo = "solis-sensor";
    rev = "v${version}";
    sha256 = "sha256-YtTwmjT3SHhXtsvglZfeL1kPwBdoEySfQHs4+S7ExJY=";
  };

  meta = with lib; {
    homepage = "https://github.com/hultenvp/solis-sensor";
    license = licenses.asl20;
    description = "HomeAssistant sensor for Solis portal platform V2 and SolisCloud portal.";
    maintainers = with maintainers; [ graham33 ];
  };
}
