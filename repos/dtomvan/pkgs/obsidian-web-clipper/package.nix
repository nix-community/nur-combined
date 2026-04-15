{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  callPackage,
  nix-update-script,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
}:
let
  xpifile = buildNpmPackage (
    finalAttrs:
    let
      isVersionMismatch = finalAttrs.version == "1.5.0";
      versionMismatch = if isVersionMismatch then "1.4.0" else finalAttrs.version;
    in
    {
      pname = "obsidian-web-clipper";
      version = "1.5.0";

      src = fetchFromGitHub {
        owner = "obsidianmd";
        repo = "obsidian-clipper";
        rev = finalAttrs.version;
        hash = "sha256-eB7v/e+DMP/MlrLp5I99qPbTYgAJCTul1+B+9A3HwyU=";
      };

      patches = lib.optionals isVersionMismatch [ ./bump-defuddle-0.17.patch ];

      npmDepsHash = "sha256-2T3hNSbL+5jsofKmRNjexNVvvgcIcWlyn+dBG4k7doE=";
      npmBuildScript = "build:firefox";

      installPhase = ''
        runHook preInstall

        cp builds/obsidian-web-clipper-${versionMismatch}-firefox.zip $out

        runHook postInstall
      '';

      passthru.updateScript = nix-update-script { };
    }
  );
in
buildFirefoxXpiAddon {
  inherit (xpifile) pname version;
  src = xpifile;
  addonId = "clipper@obsidian.md";

  meta = {
    homepage = "https://obsidian.md/clipper";
    downloadPage = "https://github.com/obsidianmd/obsidian-clipper/";
    description = "Highlight and capture the web in your favorite browser. The official Web Clipper extension for Obsidian.";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = lib.licenses.mit;
    mozPermissions = [
      "activeTab"
      "clipboardWrite"
      "contextMenus"
      "storage"
      "scripting"
      "<all_urls>"
      "http://*/*"
      "https://*/*"
    ];
  };
}
