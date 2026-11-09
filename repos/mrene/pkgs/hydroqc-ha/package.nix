{
  lib,
  fetchFromGitHub,
  buildHomeAssistantComponent,
  home-assistant,
}:

let
  hydro-quebec-api-wrapper = home-assistant.python3Packages.callPackage ./hydro-quebec-api-wrapper.nix { };
in
buildHomeAssistantComponent rec {
  owner = "hydroqc";
  domain = "hydroqc";
  version = "0.7.0";

  src = fetchFromGitHub {
    owner = "hydroqc";
    repo = "hydroqc-ha";
    tag = "v${version}";
    hash = "sha256-ULxTVySOVeTRJYohNMlIBzBAc7G+kXQ+f5YR1I6KQO8=";
  };

  dependencies = [ hydro-quebec-api-wrapper ];

  # The manifest pins an exact wrapper release; update-all.sh bumps the wrapper
  # separately, so a wrapper release ahead of the component must not fail the build.
  ignoreVersionRequirement = [ "Hydro-Quebec-API-Wrapper" ];

  passthru = { inherit hydro-quebec-api-wrapper; };

  meta = {
    description = "Hydro-Québec integration for Home Assistant";
    homepage = "https://github.com/hydroqc/hydroqc-ha";
    changelog = "https://github.com/hydroqc/hydroqc-ha/blob/v${version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    maintainers = with lib.maintainers; [ mrene ];
  };
}
