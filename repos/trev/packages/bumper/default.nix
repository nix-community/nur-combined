{
  autoPatchelfHook,
  fetchFromGitHub,
  lib,
  libgcc,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  buildRustPackage ? rustPlatform.buildRustPackage,
}:

buildRustPackage (finalAttrs: {
  pname = "bumper";
  version = "0.15.0";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+GKBb5kjlhpkqJI0XypMZB7LiH8kamVA3pMgV/D7YYc=";
  };

  cargoHash = "sha256-wouhFKRmFk85ryLbEHR2If/WKwU9QuG4mDx4+LkUZCo=";

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional (!stdenv.hostPlatform.isStatic && stdenv.hostPlatform.isLinux) autoPatchelfHook;

  buildInputs = [
    libgcc
    openssl
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      finalAttrs.pname
    ];
  };

  meta = {
    description = "Git semantic version bumper";
    mainProgram = "bumper";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://github.com/spotdemo4/bumper";
    changelog = "https://github.com/spotdemo4/bumper/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://github.com/spotdemo4/bumper/releases/tag/v${finalAttrs.version}";
  };
})
