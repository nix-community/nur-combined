{
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
  lib,
  stdenv,
  fetchFromGitHub,
  python3,
  git,
  zip,
  nix-update-script,
}:
let
  uAssets = callPackage ./uAssets.nix { };
  uProd = callPackage ./uProd.nix { };

  xpifile = stdenv.mkDerivation (finalAttrs: {
    pname = "ublock-origin";
    version = "1.67.0";

    src = fetchFromGitHub {
      owner = "gorhill";
      repo = "uBlock";
      tag = finalAttrs.version;
      hash = "sha256-q/9IkpWZST54ClGbkR+hGpT8CtHyXjVzwpL5JFvd+us=";
    };

    postPatch = ''
      patchShebangs tools
      echo "" > tools/pull-assets.sh

      mkdir -p dist/build/uAssets
      ln -s ${uAssets} dist/build/uAssets/main
      ln -s ${uProd} dist/build/uAssets/prod
    '';

    nativeBuildInputs = [
      python3
      git
      zip
    ];

    buildPhase = ''
      runHook preBuild

      ./tools/make-firefox.sh all

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      cp dist/build/uBlock0.firefox.xpi $out

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };
  });
in
buildFirefoxXpiAddon {
  inherit (xpifile) pname version;
  addonId = "uBlock0@raymondhill.net";

  src = xpifile;

  passthru = {
    inherit uAssets uProd;
  };

  meta = {
    description = "UBlock Origin - An efficient blocker for Chromium and Firefox. Fast and lean";
    homepage = "https://github.com/gorhill/uBlock";
    changelog = "https://github.com/gorhill/uBlock/blob/${xpifile.version}/CHANGELOG.md";
    maintainers = with lib.maintainers; [ dtomvan ];
    license = lib.licenses.gpl3Only;
    platforms = lib.platforms.all;
    mozPermissions = [
      "alarms"
      "dns"
      "menus"
      "privacy"
      "storage"
      "tabs"
      "unlimitedStorage"
      "webNavigation"
      "webRequest"
      "webRequestBlocking"
      "<all_urls>"
      "http://*/*"
      "https://*/*"
      "file://*/*"
      "https://easylist.to/*"
      "https://*.fanboy.co.nz/*"
      "https://filterlists.com/*"
      "https://forums.lanik.us/*"
      "https://github.com/*"
      "https://*.github.io/*"
      "https://github.com/uBlockOrigin/*"
      "https://ublockorigin.github.io/*"
      "https://*.reddit.com/r/uBlockOrigin/*"
    ];
  };
}
