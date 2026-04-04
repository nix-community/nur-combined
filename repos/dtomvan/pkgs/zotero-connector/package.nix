{
  lib,
  callPackage,
  buildFirefoxXpiAddon ? callPackage ../../lib/buildFirefoxXpiAddon.nix { },
  fetchFromGitHub,
  buildNpmPackage,
  bash,
  zip,
  jq,
  moreutils,
  nix-update-script,
}:
let
  xpifile = buildNpmPackage (finalAttrs: {
    pname = "zotero-connector";
    version = "5.0.200";

    src = fetchFromGitHub {
      owner = "zotero";
      repo = "zotero-connectors";
      rev = finalAttrs.version;
      hash = "sha256-7V2pCr+mrLB95T9HzDDFU63RS0dgpzY1b3CvZsHs4mY=";
      fetchSubmodules = true;
    };

    postPatch = ''
      # Remove selenium stuff (only used for tests and downloads bins)
      ${lib.getExe jq} 'del(.devDependencies.chromedriver) | del(.devDependencies.geckodriver)' package.json | ${moreutils}/bin/sponge package.json
    '';

    npmDepsHash = "sha256-GuRKtzxaLqGLSGEktEK6Gz2J/Wa4El4A5yMGirh9NZE=";

    env = {
      PUPPETEER_SKIP_DOWNLOAD = "1";
    };

    buildPhase = ''
      runHook preBuild

      ${lib.getExe bash} build.sh -p b

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      pushd build/firefox/
      ${lib.getExe zip} -r $out *
      popd

      runHook postInstall
    '';

    passthru.updateScript = nix-update-script { };
  });
in
buildFirefoxXpiAddon {
  inherit (xpifile) pname version;
  src = xpifile;

  addonId = "zotero@chnm.gmu.edu";

  meta = with lib; {
    homepage = "https://www.zotero.org/";
    description = "Save references to Zotero from your web browser";
    license = licenses.agpl3Plus;
    platforms = platforms.all;
    mozPermissions = [
      "http://*/*"
      "https://*/*"
      "tabs"
      "contextMenus"
      "cookies"
      "storage"
      "scripting"
      "webRequest"
      "webRequestBlocking"
      "webNavigation"
      "declarativeNetRequest"
      "management"
      "clipboardWrite"
    ];

    maintainers = with lib.maintainers; [ dtomvan ];
  };
}
