{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
}:

buildNpmPackage (finalAttrs: {
  pname = "tab-session-manager-firefox";
  version = "7.4.0";

  extid = "Tab-Session-Manager@sienori";

  src = fetchFromGitHub {
    owner = "sienori";
    repo = "Tab-Session-Manager";
    rev = finalAttrs.version;
    hash = "sha256-d4tSaA9IlPEBi+kLGtplogui/RdCvpOzP3wMxuyWRZM=";
  };

  npmDepsHash = "sha256-Xwwekhwog9EBFzi33Bm4K0+vQOG4Sew9DWPegZF3hFI=";

  preBuild = ''
        cat > src/credentials.js <<'EOF'
    export const clientId = "";
    export const clientSecret = "";
    EOF
  '';

  buildPhase = ''
    runHook preBuild
    npm run build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    xpi=$(find dist -name 'tab_session_manager-for-firefox-*.zip' -print -quit)
    test -n "$xpi"

    install -Dm644 "$xpi" "$out/${finalAttrs.extid}.xpi"
    ln -s "${finalAttrs.extid}.xpi" "$out/tab-session-manager.xpi"

    runHook postInstall
  '';

  doCheck = false;

  passthru = {
    inherit (finalAttrs) extid;
  };

  meta = {
    changelog = "https://github.com/sienori/Tab-Session-Manager/releases/tag/${finalAttrs.version}";
    description = "Tab Session Manager Firefox add-on built from source";
    homepage = "https://tab-session-manager.sienori.com";
    license = lib.licenses.mpl20;
    platforms = lib.platforms.all;
  };
})
