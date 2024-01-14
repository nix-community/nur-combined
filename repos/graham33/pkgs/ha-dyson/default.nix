{ lib
, fetchFromGitHub
, buildHomeAssistantComponent
, python
, libdyson
, setuptools
}:

buildHomeAssistantComponent rec {
  owner = "graham33";
  domain = "dyson_local";
  version = "0.16.4-4";
  format = "pyproject";

  src = fetchFromGitHub {
    owner = "shenxn";
    repo = "ha-dyson";
    rev = "v${version}";
    sha256 = "sha256-HLY8+eXzfVasO1EVZQ46mooJ4beID01RvYo4BfjHfnc=";
  };

  propagatedBuildInputs = [
    libdyson
    setuptools
  ];

  meta = with lib; {
    homepage = "https://github.com/shenxn/ha-dyson";
    license = licenses.mit;
    description = "HomeAssistant custom integration for Dyson";
    maintainers = with maintainers; [ graham33 ];
  };
}
