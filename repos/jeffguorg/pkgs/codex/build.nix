{
  lib,
  stdenv,
  rustPlatform,
  fetchurl,
  installShellFiles,
  clang,
  cmake,
  gitMinimal,
  libclang,
  makeBinaryWrapper,
  pkg-config,
  openssl,
  libcap,
  ripgrep,
  versionCheckHook,
  installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform,
  sources,
}:
let
  codexSource = sources.codex;
  rustTarget = stdenv.hostPlatform.rust.rustcTarget or stdenv.hostPlatform.config;
  rustyV8Version = "150.4.0";
  rustyV8Profile = "ptrcomp_sandbox_release";
  rustyV8ReleaseUrl = "https://github.com/openai/codex/releases/download/rusty-v8-v${rustyV8Version}";
  rustyV8Archive = fetchurl {
    url = "${rustyV8ReleaseUrl}/librusty_v8_${rustyV8Profile}_${rustTarget}.a.gz";
    hash = {
      x86_64-unknown-linux-gnu = "sha256-o1x10fJuapg4haRbM0kKTr5U8FBQVosyuJz7QhswtYM=";
      aarch64-unknown-linux-gnu = "sha256-0VF+7UBUaFNwKbAF1f6ZfsdNXI01H5FrOm3yC30oEbo=";
      x86_64-apple-darwin = "sha256-4Nm7ZOizoDTCkwyDly8/NXYCERSDQvoEB7OCUO8zCFY=";
      aarch64-apple-darwin = "sha256-AK27SHmISMd1UEQcaGc6XoUpuOG3PqvN7iMss5tA9KE=";
    }.${rustTarget};
  };
  rustyV8Binding = fetchurl {
    url = "${rustyV8ReleaseUrl}/src_binding_${rustyV8Profile}_${rustTarget}.rs";
    hash = {
      x86_64-unknown-linux-gnu = "sha256-dyeCauR5vbZF6Acjn7EtH44uI956bPFvXuWSaQ0dhQY=";
      aarch64-unknown-linux-gnu = "sha256-dyeCauR5vbZF6Acjn7EtH44uI956bPFvXuWSaQ0dhQY=";
      x86_64-apple-darwin = "sha256-ylrfDPicmnCtRgrnNkiy/om3SqETs8t/dXtqArdYOU8=";
      aarch64-apple-darwin = "sha256-ylrfDPicmnCtRgrnNkiy/om3SqETs8t/dXtqArdYOU8=";
    }.${rustTarget};
  };
in
rustPlatform.buildRustPackage {
  pname = "codex";
  version = lib.removePrefix "rust-v" codexSource.version;

  src = codexSource.src;
  sourceRoot = "${codexSource.src.name}/codex-rs";

  cargoLock = codexSource.cargoLock."codex-rs/Cargo.lock";

  cargoBuildFlags = [
    "--bin"
    "codex"
    "--bin"
    "codex-code-mode-host"
  ];

  nativeBuildInputs = [
    clang
    cmake
    gitMinimal
    installShellFiles
    makeBinaryWrapper
    pkg-config
  ];

  buildInputs =
    [
      libclang
      openssl
    ]
    ++ lib.optionals stdenv.isLinux [
      libcap
    ];

  env = {
    LIBCLANG_PATH = "${lib.getLib libclang}/lib";
    RUSTY_V8_ARCHIVE = rustyV8Archive;
    RUSTY_V8_SRC_BINDING_PATH = rustyV8Binding;
    NIX_CFLAGS_COMPILE = toString (
      lib.optionals stdenv.cc.isGNU [
        "-Wno-error=stringop-overflow"
      ]
      ++ lib.optionals stdenv.cc.isClang [
        "-Wno-error=character-conversion"
      ]
    );
  };

  doCheck = false;

  postInstall = lib.optionalString installShellCompletions ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash 2>/dev/null) \
      --fish <($out/bin/codex completion fish 2>/dev/null) \
      --zsh <($out/bin/codex completion zsh 2>/dev/null)
  '';

  postFixup = ''
    wrapProgram $out/bin/codex --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Lightweight coding agent that runs in your terminal";
    homepage = "https://github.com/openai/codex";
    changelog = "https://raw.githubusercontent.com/openai/codex/refs/tags/${codexSource.version}/CHANGELOG.md";
    license = lib.licenses.asl20;
    mainProgram = "codex";
    platforms = lib.platforms.unix;
  };
}
