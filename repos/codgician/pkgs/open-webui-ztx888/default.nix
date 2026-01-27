{
  lib,
  fetchFromGitHub,
  fetchNpmDeps,
  open-webui
}:

let
  version = "0.7.3-7";
  hash = "sha256-aLWVGTl95NBIuBzAxWKx9M5w+jl8YNc4x2OCQOZvU64=";
  npmDepsHash = "sha256-lOtrYlSuX6M1xQsO2QE1QS8PrZEEdWWtius5FnvDjko=";

  src = fetchFromGitHub {
    owner = "ztx888";
    repo = "open-webui";
    rev = "v${version}";
    inherit hash;
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

  meta = with lib; oldAttrs.meta // {
    description = "Fork of Open WebUI with additional features and enhancements by ztx888";
    maintainers = with maintainers; [ codgician ];
    platforms = [ "x86_64-linux" "x86_64-darwin" ];
  };
})
