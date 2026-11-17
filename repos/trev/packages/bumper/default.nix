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
  version = "0.38.0";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "bumper";
    rev = "v${final.version}";
    hash = "sha256-9XLWj0xS1HwvNeBM9pUsXuZVLT1flsaDeNZkcP2N4Q4=";
  };

  cargoHash = "sha256-RCHV9sqJDMgl1x35T8b07x7HtDAVij6LEsdhwTeH51U=";

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
