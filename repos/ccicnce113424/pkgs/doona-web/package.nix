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
}:
let
  pnpm = pnpm_11;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "doona-web";
  version = "0.1.0-beta.19";

  src = fetchFromGitHub {
    owner = "Zakkaus";
    repo = "doona";
    tag = "v${finalAttrs.version}";
    hash = "sha256-54jDpKe8hArwtXEUf39Q/dtCAFs+/1/Uc0B8g9b9obI=";
  };

  __structuredAttrs = true;
  strictDeps = true;

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-N4Goi5+BddeW0C+NA+h0Ae2U9RWbVCmpliExQjySlUc=";
  };

  nativeBuildInputs = [
    pnpmConfigHook
    pnpmBuildHook
    pnpm
    nodejs
  ];

  pnpmBuildScript = "build";

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/doona-web
    cp -r dist/. $out/share/doona-web

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--use-github-releases"
      "--version=unstable"
    ];
  };

  meta = {
    description = "Web UI for the daeuniverse engines";
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
})
