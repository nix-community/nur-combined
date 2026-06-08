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
    version = "1.10.3";

    src = fetchFromGitHub {
      owner = "keepassxreboot";
      repo = "keepassxc-browser";
      tag = "${finalAttrs.version}";
      hash = "sha256-df9K+ghV/w0xtTvLlKu1xU0Vl9HLLiL5eNPZjZqU0+s=";
    };

    npmDepsHash = "sha256-GNoytFmX+YI8jseZc7hFTMiuKxuP6Ow97stiusDRpCg=";

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
