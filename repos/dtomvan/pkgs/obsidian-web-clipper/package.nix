{
  fetchFromGitHub,
  lib,
  buildNpmPackage,
  callPackage,
  nix-update-script,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
}:
let
  xpifile = buildNpmPackage (finalAttrs: {
    pname = "obsidian-web-clipper";
    version = "1.0.2";

    src = fetchFromGitHub {
      owner = "obsidianmd";
      repo = "obsidian-clipper";
      rev = finalAttrs.version;
      hash = "sha256-bub3/ip0mBi41HYQBZX09VGrK6+xeTW9ypW+yaYNPtQ=";
    };

    npmDepsHash = "sha256-5aVJbWZ0ZE4+dLR/GPvwanirBPALXMdMXN1SgeT4jJ4=";
    npmBuildScript = "build:firefox";

    installPhase = ''
      runHook preInstall

      cp builds/obsidian-web-clipper-${finalAttrs.version}-firefox.zip $out

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };
  });
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
