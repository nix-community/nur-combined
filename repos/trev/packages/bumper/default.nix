{
  autoPatchelfHook,
  fetchFromGitea,
  lib,
  libgcc,
  libgit2,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  buildRustPackage ? rustPlatform.buildRustPackage,
}:

buildRustPackage (final: {
  pname = "bumper";
  version = "1.0.1";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "bumper";
    rev = "v${final.version}";
    hash = "sha256-6ONsnB23v4RkdvPwhfLhlTIRugpWP+333XRbllRDpq4=";
  };

  cargoHash = "sha256-lVgYrjPQTZbtyqfoiOc4FtaVPqq6xCqB4DpuKCxDUKM=";

  nativeBuildInputs = [
    pkg-config
  ]
  ++ lib.optional (!stdenv.hostPlatform.isStatic && stdenv.hostPlatform.isLinux) autoPatchelfHook;

  buildInputs = [
    libgcc
    libgit2
    openssl
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--commit"
      final.pname
    ];
  };

  meta = {
    description = "Git semantic version bumper";
    mainProgram = "bumper";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
    homepage = "https://trev.zip/llc/bumper";
    changelog = "https://trev.zip/llc/bumper/releases/tag/v${final.version}";
    downloadPage = "https://trev.zip/llc/bumper/releases/tag/v${final.version}";
  };
})
