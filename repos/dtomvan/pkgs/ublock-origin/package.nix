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
  uAssets = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "78372c673c25a0df4edf9d77846893280a7cd6e0";
    hash = "sha256-uPQomlwgJphEq5yheCfUMjyNBIBVUJVP4Heo7gw+JiM=";
  };
  uProd = fetchFromGitHub {
    owner = "ublockorigin";
    repo = "uAssets";
    rev = "d40038fc816d1403cde41ca234d2349fd0a1bc73";
    hash = "sha256-Dwt6th0QCHmWIHtXgl+5sLSXhGSLJUpeTB52w5jdPew=";
  };
  xpifile = stdenv.mkDerivation (finalAttrs: {
    pname = "ublock-origin";
    version = "1.64.1b0";

    src = fetchFromGitHub {
      owner = "gorhill";
      repo = "uBlock";
      tag = finalAttrs.version;
      hash = "sha256-byYEhrUN6mLpbqNCpm2tUcB/6ftO2hvqAhJ1MQ2xGBY=";
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
