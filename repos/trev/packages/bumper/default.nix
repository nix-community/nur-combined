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
  version = "0.37.0";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "bumper";
    rev = "v${final.version}";
    hash = "sha256-4jpdd2v/w2+U+1Y3aiX6yguU6pgDo5C8mTustdzsA58=";
  };

  cargoHash = "sha256-S+WFkuWj6zp1NFsv8tEhnQ9Zx/m7AxMoauXBslzLuqw=";

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
