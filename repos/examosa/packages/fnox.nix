{
  lib,
  stdenv,
  rustPlatform,
  fetchFromGitHub,
  installShellFiles,
  nix-update-script,
  pkg-config,
  dbus,
  udev,
  openssl,
  usage,
}:
rustPlatform.buildRustPackage (finalAttrs: {
  pname = "fnox";
  version = "1.29.0";

  __structuredAttrs = true;

  src = fetchFromGitHub {
    owner = "jdx";
    repo = "fnox";
    tag = "v${finalAttrs.version}";
    hash = "sha256-sXFcvpAcHrzRbqYLIrq844TH1dHY1G23QIQoIcsCLGY=";
  };

  cargoHash = "sha256-BhBWghjPC8qs5oKECmddV250YO4/hSWupOz+J9DYKog=";

  nativeBuildInputs = [
    installShellFiles
    pkg-config
  ];

  buildInputs =
    [
      dbus
      openssl
    ]
    ++ lib.optional stdenv.hostPlatform.isLinux udev;

  postPatch = ''
    substituteInPlace ./src/commands/completion.rs \
      --replace-fail '"usage"' "\"$JDX_USAGE_BIN\""
  '';

  postInstall = ''
    completions=(--cmd fnox)

    for shell in {ba,fi,z}sh; do
      completion=fnox.$shell

      $JDX_USAGE_BIN generate completion $shell fnox \
        --file fnox.usage.kdl > $completion

      completions+=(--$shell $completion)
    done

    installShellCompletion "''${completions[@]}"

    $JDX_USAGE_BIN generate manpage --file fnox.usage.kdl --out-file fnox.1
    installManPage fnox.1
  '';

  env = {
    JDX_USAGE_BIN = lib.getExe usage;
    OPENSSL_NO_VENDOR = true;
  };

  passthru.updateScript = nix-update-script {};

  meta = {
    description = "Encrypted/remote secret manager";
    homepage = "https://github.com/jdx/fnox";
    changelog = "https://github.com/jdx/fnox/blob/${finalAttrs.src.rev}/CHANGELOG.md";
    license = lib.licenses.mit;
    mainProgram = "fnox";
  };
})
