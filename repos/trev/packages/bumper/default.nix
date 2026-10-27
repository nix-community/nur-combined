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
  version = "0.34.0";

  src = fetchFromGitea {
    domain = "trev.zip";
    owner = "llc";
    repo = "bumper";
    rev = "v${final.version}";
    hash = "sha256-qCneyr/wF3U6pmfPws1zAEdlAB5t8q2XRaxdXALw73o=";
  };

  cargoHash = "sha256-jtWaipT1dNPc8JmJYcfLERCl/CXYTb7QL8jtz6xYR50=";

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
