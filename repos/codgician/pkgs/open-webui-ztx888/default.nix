{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  open-webui,
}:

let
  version = "0.7.3-8";
  # Use commit SHA to avoid ambiguity when both tag and branch have the same name
  rev = "32ec1ec3f209a29ec8a976d76bb9f3c3cfce6e56";
  hash = "sha256-4Xs+dnYSMNxf1g608KXOsyu7R4enpiJvD/w6YdSoayY=";
  npmDepsHash = "sha256-mjjVoMOseCaPqas+AEJY3LL2dRo8yLHlWnleXZU/AS0=";

  src = fetchFromGitHub {
    owner = "ztx888";
    repo = "open-webui";
    inherit rev hash;
  };

  frontend = open-webui.frontend.overrideAttrs (oldAttrs: {
    inherit version src;
    npmDeps = fetchNpmDeps {
      inherit src;
      hash = npmDepsHash;
    };
  });
in
open-webui.overrideAttrs (oldAttrs: {
  pname = "open-webui-ztx888";
  inherit src version;

  makeWrapperArgs = [ "--set FRONTEND_BUILD_DIR ${frontend}/share/open-webui" ];

  passthru = oldAttrs.passthru // {
    inherit frontend;
    updateScript = ./update.sh;
  };

  meta =
    with lib;
    oldAttrs.meta
    // {
      description = "Fork of Open WebUI with additional features and enhancements by ztx888";
      maintainers = with maintainers; [ codgician ];
      platforms = [
        "x86_64-linux"
        "x86_64-darwin"
      ];
    };
})
