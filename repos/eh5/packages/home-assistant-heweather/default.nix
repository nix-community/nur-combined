{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:
buildHomeAssistantComponent rec {
  owner = "c1pher-cn";
  domain = "heweather";
  version = "2.4.7";

  src = fetchFromGitHub {
    inherit owner;
    repo = domain;
    tag = "v${version}";
    hash = "sha256-jz8/cQSt/THH9LsH6c3AIu91eDAEISpokoYoRJUFnjM=";
  };

  dependencies = with home-assistant.python3Packages; [
    cryptography
    pyjwt
  ];

  meta = {
    description = "Home Assistant integration for QWeather/HeWeather";
    homepage = "https://github.com/c1pher-cn/heweather";
    license = lib.licenses.unfree;
  };
}
