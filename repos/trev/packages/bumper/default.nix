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
  version = "0.21.1";

  src = fetchFromGitHub {
    owner = "spotdemo4";
    repo = "bumper";
    tag = "v${finalAttrs.version}";
    hash = "sha256-+mg/yL1w0xbN8LVD5eHIagg40yB4xH1rjhTf9JqQL5c=";
  };

  cargoHash = "sha256-dP/cc00+A1tZHjnqtleKutdxwfdjD1OGkd38K7tVS7Q=";

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
