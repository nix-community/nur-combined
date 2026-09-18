{
  lib,
  stdenv,
  nix-update-script,
  fetchFromGitHub,
  fetchPnpmDeps,
  pnpm_10,
  pnpmConfigHook,
  nodejs_24,
}:

let
  pnpm = pnpm_10;
  nodejs = nodejs_24;
in
stdenv.mkDerivation (finalAttrs: {
  pname = "sable-unwrapped";
  version = "1.22.4";

  __structuredAttrs = true;
  strictDeps = true;

  src = fetchFromGitHub {
    owner = "SableClient";
    repo = "Sable";
    tag = "v${finalAttrs.version}";
    hash = "sha256-15iUAT0C5b1qLv5pgBpzGsOGIH5dbgpmjQc0Z6uaRYY=";
  };

  patches = [
    # Revert Firebase config
    ./0001-Revert-chore-add-Firebase-config-for-native-FCM-push.patch
  ];

  nativeBuildInputs = [
    pnpm
    pnpmConfigHook
    nodejs
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-paJKHLFT78b/OKg/xWYUquET5JjF3P1kNZXRTP0IIsY=";
  };

  env = {
    VITE_BUILD_HASH = finalAttrs.src.rev;
    SABLE_BUILD_FLAVOR = "stable";
  };

  buildPhase = ''
    runHook preBuild

    pnpm -- config set nodeOptions "--max-old-space-size=4096"
    pnpm build

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    cp -r dist $out

    runHook postInstall
  '';

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "An almost stable Matrix client";
    homepage = "https://github.com/SableClient/Sable";
    changelog = "https://github.com/SableClient/Sable/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.agpl3Only;
    maintainers = with lib.maintainers; [ bartoostveen ];
    platforms = lib.platforms.all;
  };
})
