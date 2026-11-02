{
  autoPatchelfHook,
  fetchFromGitea,
  lib,
  libgcc,
  nix-update-script,
  openssl,
  pkg-config,
  rustPlatform,
  stdenv,
  buildRustPackage ? rustPlatform.buildRustPackage,
}:

buildRustPackage (final: {
  pname = "bumper";
  version = "0.35.1";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "bumper";
    rev = "v${final.version}";
    hash = "sha256-EhtO7LU5/wr2p5C9ojhkZLfLVGDCSvvKoiMO6fOTzLI=";
  };

  cargoHash = "sha256-h7v6qdQgOpVR/hAlfzcyV6JOpzYyT4yanhhL6gPcax4=";

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
