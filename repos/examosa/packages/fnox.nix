{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  perl,
  pkg-config,
  dbus,
  udev,
  usage,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fnox";
  version = "1.31.1";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "fnox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-PAzXu+fltWJXn30RVRUfjCiUUFnt4mb/yeyxM5wCtG8=";
  };

  cargoHash = "sha256-ImD2PEtoTW1ktNpSzGO0ENyXQ/A4f0ydHqZhSIgNroE=";

  nativeBuildInputs =
    [
      installShellFiles
      pkg-config
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux perl;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [dbus udev];

  postPatch = ''
    substituteInPlace ./src/commands/completion.rs \
      --replace-fail '"usage"' "\"$JDX_USAGE_BIN\""
  '';

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
    description = "Encrypted/remote secret manager";
    homepage = "https://github.com/jdx/fnox";
    changelog = "https://github.com/jdx/fnox/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "fnox";
  };
})
