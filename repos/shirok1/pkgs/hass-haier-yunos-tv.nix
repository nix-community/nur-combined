{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent {
  owner = "shirok1";
  domain = "haier_tv";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "shirok1";
    repo = "hass-haier-yunos-tv";
    rev = "74676f57385917e5119656ce6dcc77e29c20f910";
    hash = "sha256-02Kko7+ljDqfnm0cOd2554v46w8FbypeCpnunj5HLPE=";
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
