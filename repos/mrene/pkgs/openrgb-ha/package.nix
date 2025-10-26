{
  lib,
  buildHomeAssistantComponent,
  fetchFromGitHub,
  home-assistant,
}:

buildHomeAssistantComponent rec {
  pname = "openrgb-ha";
  version = "2.4";

  owner = "koying";
  domain = "openrgb";

  # src = fetchFromGitHub {
  #   owner = "koying";
  #   repo = "openrgb_ha";
  #   rev = "v${version}";
  #   hash = "sha256-Siu5tItrOWyzIHBw/EjfzgzE5NXMUFUnmXdMucRCVCs=";
  # };

  src = fetchFromGitHub {
    owner = "Bluscream";
    repo = "openrgb_ha";
    rev = "dbdf34ca43d2def17f9590e6eab993e03b068ee6";
    hash = "sha256-PvyzlK5LfqkgMoUErNLihXfVK3Uv6cNzPgp+DXIPRCM=";
  };

  # openrgb-python==0.3.1 expected, but got 0.3.2
  dontCheckManifest = true;

  dependencies = with home-assistant.python.pkgs; [
    openrgb-python
  ];

  meta = {
    description = "OpenRGB integration for Home Assistant";
    homepage = "https://github.com/koying/openrgb_ha";
    license = lib.licenses.mit; # FIXME: nix-init did not find a license
    maintainers = with lib.maintainers; [ ];
    mainProgram = "openrgb-ha";
    platforms = lib.platforms.linux;
  };
}
