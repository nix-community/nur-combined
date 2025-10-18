{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
  buildNpmPackage,
  fetchFromGitHub,
}:
let
  xpifile = buildNpmPackage (finalAttrs: {
    pname = "keepassxc-browser";
    version = "1.9.10";

    src = fetchFromGitHub {
      owner = "keepassxreboot";
      repo = "keepassxc-browser";
      tag = "${finalAttrs.version}";
      hash = "sha256-y3k3Yw+2dhnFTNxSLM6MEVSSQYinBoX6TXsGrHerb6I=";
    };

    npmDepsHash = "sha256-flWQzqqk+DWT6Ban5OhfYDZSqaibUvXk+hsO3T8kBAU=";

    npmBuildFlags = [
      "--"
      "--skip-translations"
    ];

    installPhase = ''
      runHook preInstall

      cp ${finalAttrs.pname}_${finalAttrs.version}_firefox.zip $out

      runHook postInstall
    '';
  });
in
buildFirefoxXpiAddon {
  inherit (xpifile) pname version;
  src = xpifile;

  addonId = "keepassxc-browser@keepassxc.org";

  meta = {
    description = "KeePassXC Browser Extension";
    homepage = "https://github.com/keepassxreboot/keepassxc-browser";
    changelog = "https://github.com/keepassxreboot/keepassxc-browser/blob/${xpifile.src.rev}/CHANGELOG";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    mozPermissions = [
      "activeTab"
      "clipboardWrite"
      "contextMenus"
      "cookies"
      "nativeMessaging"
      "notifications"
      "storage"
      "tabs"
      "webNavigation"
      "webRequest"
      "webRequestBlocking"
      "https://*/*"
      "http://*/*"
      "https://api.github.com/"
      "<all_urls>"
    ];
  };
}
