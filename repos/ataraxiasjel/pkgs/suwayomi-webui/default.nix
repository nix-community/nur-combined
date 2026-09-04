{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpmConfigHook,
  pnpm_11,
  nodejs_24,
  _experimental-update-script-combinators,
  nix-update-script,
}:

let
  pnpm = pnpm_11;
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "suwayomi-webui";
  version = "20260726.01";
  revision = "3379";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "Suwayomi";
    repo = "Suwayomi-WebUI";
    tag = "v${finalAttrs.version}";
    hash = "sha256-1eYVgoYSBX2ZHTZUXi0TN17m1UresEfdTc4Sq8rykbU=";
  };

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-tbaNDI2kJKwriZGaSgqQAKPAB8ser53Nc6J4Jp6aqFY=";
  };

  nativeBuildInputs = [
    nodejs_24
    pnpmConfigHook
    pnpm
  ];

  postPatch = ''
    substituteInPlace package.json \
      --replace-fail "project" "suwayomi-webui"
  '';

  buildPhase = ''
    runHook preBuild

    pnpm setup-env-files

    node node_modules/vite/bin/vite.js build

    echo "r${finalAttrs.revision}" > build/revision
    pnpm build-md5

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/suwayomi-server
    cp -a build $out/share/suwayomi-webui
    mv buildZip/md5sum $out/share/suwayomi-server

    runHook postInstall
  '';

  passthru.updateScript = _experimental-update-script-combinators.sequence [
    (nix-update-script { })
    [
      ./update-rev.sh
      "./pkgs/suwayomi-webui"
    ]
  ];

  meta = {
    description = "The default client for Suwayomi-Server";
    homepage = "https://github.com/Suwayomi/Suwayomi-WebUI";
    downloadPage = "https://github.com/Suwayomi/Suwayomi-WebUI/releases/";
    changelog = "https://github.com/Suwayomi/Suwayomi-WebUI/releases/tag/v${finalAttrs.version}";
    license = lib.licenses.mpl20;
    inherit (nodejs_24.meta) platforms;
    maintainers = with lib.maintainers; [
      nanoyaki
      ratcornu
      ataraxiasjel
    ];
  };
})
