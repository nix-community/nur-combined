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
  version = "0.14.2";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-hv2QQF0ZNEwXn0dlya5ymI6IpFx9KUqP2o9bVWleOV4=";
  };

  cargoHash = "sha256-9rZYS7m+5RGj7WLoQuIlsWavE6ShBkfVGNczCSyJvZ4=";

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
