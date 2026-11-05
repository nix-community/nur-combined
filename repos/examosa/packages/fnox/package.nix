{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  cacert,
  gitMinimal,
  perl,
  pkg-config,
  dbus,
  udev,
  usage,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fnox";
  version = "1.47.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "fnox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-3Z/JjP8mjzCFCZUhbD5BnRh39loLt2g4dqkQqWCeH5I=";
  };

  cargoHash = "sha256-VokoB+4gheYF0HunlOYYA+gu4pimb6uG9qfNZWeubMU=";

  nativeBuildInputs = [
    installShellFiles
    perl
    pkg-config
  ];

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [dbus udev];

  nativeCheckInputs = [cacert gitMinimal];

  postInstall = ''
    completions=()

    for shell in {ba,fi,z}sh; do
      completion=fnox.$shell

      $JDX_USAGE_BIN generate completion $shell fnox \
        --file fnox.usage.kdl > $completion

      completions+=($completion)
    done

    installShellCompletion "''${completions[@]}"

    $JDX_USAGE_BIN generate manpage --file fnox.usage.kdl --out-file fnox.1
    installManPage fnox.1
  '';

  env.JDX_USAGE_BIN = lib.getExe usage;

  passthru.updateScript = nix-update-script {extraArgs = ["--use-github-releases"];};

  meta = {
    broken = lib.versionOlder usage.version "6";
    description = "Encrypted/remote secret manager";
    homepage = "https://github.com/jdx/fnox";
    changelog = "https://github.com/jdx/fnox/blob/${finalAttrs.src.tag}/CHANGELOG.md";
    license = lib.licenses.mit;
    maintainers = [lib.maintainers.examosa];
    mainProgram = "fnox";
  };
})
