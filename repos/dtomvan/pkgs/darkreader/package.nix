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
    pname = "darkreader";
    version = "4.9.108";

    src = fetchFromGitHub {
      owner = "darkreader";
      repo = "darkreader";
      rev = "v${finalAttrs.version}";
      hash = "sha256-IUoxSsFgq3OX6JyHH7g4voliMYkD7yPo7Ku0wrk/2HU=";
    };

    npmDepsHash = "sha256-/S8vk5SYjKJM5RlIfYqcNbTh3QUNpBB6lbnuIgGz9go=";
    npmBuildScript = "build:firefox";

    installPhase = ''
      runHook preInstall

      cp build/release/darkreader-firefox.xpi $out

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };
  });
in
buildFirefoxXpiAddon rec {
  inherit (xpifile) pname version;
  src = xpifile;

  addonId = "addon@darkreader.org";

  meta = {
    description = "Dark Reader Chrome and Firefox extension";
    homepage = "https://github.com/darkreader/darkreader";
    changelog = "https://github.com/darkreader/darkreader/blob/${version}/CHANGELOG.md";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    mozPermissions = [
      "alarms"
      "contextMenus"
      "storage"
      "tabs"
      "theme"
      "<all_urls>"
    ];
  };
}
