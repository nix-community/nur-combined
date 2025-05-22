{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
  buildNpmPackage,
  fetchFromGitHub,
  nix-update-script,
}:
let
  xpifile = buildNpmPackage (finalAttrs: {
    pname = "sidebery";
    version = "5.3.3";

    src = fetchFromGitHub {
      owner = "mbnuqw";
      repo = "sidebery";
      rev = "v${finalAttrs.version}";
      hash = "sha256-wJqEuThoU5s5tYI3bpCBF5ADbLv8qeG3dDbOdL6eDoA=";
    };

    npmDepsHash = "sha256-YRfKI61RPvRUdgUElGgPolYNiUmd7S7uV2Fyb+ThOCM=";

    buildPhase = ''
      runHook preBuild

      npm run build
      npm run build.ext

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp dist/${finalAttrs.pname}-${finalAttrs.version}.zip $out

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };
  });
in
buildFirefoxXpiAddon rec {
  inherit (xpifile) pname version;
  src = xpifile;

  addonId = "{3c078156-979c-498b-8990-85f7987dd929}";

  meta = {
    description = "Firefox extension for managing tabs and bookmarks in sidebar";
    homepage = "https://github.com/mbnuqw/sidebery";
    changelog = "https://github.com/mbnuqw/sidebery/blob/${version}/CHANGELOG.md";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mozPermissions = [
      "activeTab"
      "tabs"
      "contextualIdentities"
      "cookies"
      "storage"
      "unlimitedStorage"
      "sessions"
      "menus"
      "menus.overrideContext"
      "search"
      "theme"
      "identity"
    ];
  };
}
