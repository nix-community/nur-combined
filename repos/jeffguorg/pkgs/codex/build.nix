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
  rustyV8Archive = fetchurl {
    url = "https://github.com/denoland/rusty_v8/releases/download/v146.4.0/librusty_v8_release_${rustTarget}.a.gz";
    hash = "sha256-5ktNmeSuKTouhGJEqJuAF4uhA4LBP7WRwfppaPUpEVM=";
  };
in
rustPlatform.buildRustPackage {
  pname = "codex";
  version = lib.removePrefix "rust-v" codexSource.version;

  src = codexSource.src;
  sourceRoot = "${codexSource.src.name}/codex-rs";

  cargoLock = codexSource.cargoLock."codex-rs/Cargo.lock";

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
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
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
