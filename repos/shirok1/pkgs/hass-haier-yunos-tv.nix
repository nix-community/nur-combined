{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent {
  owner = "shirok1";
  domain = "haier_tv";
  version = "0.1.1-unstable";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-haier-yunos-tv";
    rev = "295dc0cce5736158f35120d31118e727c1721386";
    hash = "sha256-6Bhu9X0yxs2OEQWmVjpywzT8uHYwiOaAldfY4HA2kT8=";
  };

  dependencies =
    with home-assistant.python3Packages;
    [
      adb-shell
    ]
    ++ adb-shell.optional-dependencies.async;

  meta = {
    description = "Native ADB control for Haier YunOS televisions in Home Assistant";
    homepage = "https://github.com/shirok1/hass-haier-yunos-tv";
    license = lib.licenses.asl20;
  };
}
