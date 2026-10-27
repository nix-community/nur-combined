{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpmBuildHook,
  pnpm_11,
  nodejs,
  nix-update-script,
  _experimental-update-script-combinators,
  isLite ? false,
}:
let
  pnpm = pnpm_11;
  # The lite edition is a separate pnpm workspace inside apps/lite. It shares
  # source files with the standard app and also resolves `openapi-fetch` and
  # `typescript` (via tools/) from the root node_modules, so both dependency
  # trees must be installed.
  liteRoot = "apps/lite";
in
stdenvNoCC.mkDerivation (
  finalAttrs:
  let
    rootPnpmDeps = fetchPnpmDeps {
      pname = "doona-web";
      inherit (finalAttrs) version src;
      inherit pnpm;
      fetcherVersion = 4;
      hash = "sha256-N4Goi5+BddeW0C+NA+h0Ae2U9RWbVCmpliExQjySlUc=";
    };

    litePnpmDeps = fetchPnpmDeps {
      pname = "doona-lite-deps";
      inherit (finalAttrs) version;
      src = "${finalAttrs.src}/${liteRoot}";
      inherit pnpm;
      fetcherVersion = 5;
      hash = "sha256-82eIKB4DtO4x3INls04jBJLNzNylgTmCCp8q6HUGPfY=";
    };
  in
  {
    pname = "doona-${if isLite then "lite" else "web"}";
    version = "0.1.0-rc.2";

    src = fetchFromGitHub {
      owner = "Zakkaus";
      repo = "doona";
      tag = "v${finalAttrs.version}";
      hash = "sha256-8nz7ijd/SvZ8K7j+78hzToDRsLqwptCIIAAPZY7FQCE=";
    };

    __structuredAttrs = true;
    strictDeps = true;

    # Both attrs expose their own pnpmDeps, so nix-update can refresh each hash.
    pnpmDeps = if isLite then litePnpmDeps else rootPnpmDeps;

    nativeBuildInputs = [
      pnpmConfigHook
      pnpmBuildHook
      pnpm
      nodejs
    ];

    # The lite build also imports the root workspace's node_modules; install
    # those before the automatic hook installs the lite tree.
    preConfigure = lib.optionalString isLite ''
      pnpmDeps=${rootPnpmDeps} pnpmRoot= pnpmConfigHook
    '';

    pnpmRoot = lib.optionalString isLite liteRoot;
    pnpmBuildScript = "build";

    installPhase = ''
      runHook preInstall

      mkdir -p $out
      cp -r ${if isLite then liteRoot else "."}/dist/. $out/
      rm -rf $out/.vite

      runHook postInstall
    '';

    passthru.updateScript =
      if isLite then
        null
      else
        _experimental-update-script-combinators.sequence [
          (nix-update-script {
            extraArgs = [
              "--use-github-releases"
              "--version=unstable"
            ];
          })
          # Refresh the lite workspace's dependency hash at the new version.
          (nix-update-script {
            attrPath = "doona-lite";
            extraArgs = [ "--version=skip" ];
          })
        ];

    meta = {
      description = "Web UI for the daeuniverse engines${lib.optionalString isLite " (lite edition)"}";
      homepage = "https://github.com/Zakkaus/doona";
      license = with lib.licenses; [
        gpl3Only
        bsd0
        asl20
        bsd3
        isc
        mit
        cc-by-30
        cc-by-40
        cc-by-sa-40
        cc0
        ofl
      ];
      maintainers = with lib.maintainers; [ ccicnce113424 ];
    };
  }
)
