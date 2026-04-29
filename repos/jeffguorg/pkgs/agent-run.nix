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
  sources,
}:
let
  agentRunSource = sources.agent-run;
  shortCommit = lib.substring 0 7 agentRunSource.version;
in
rustPlatform.buildRustPackage {
  pname = "agent-run";
  version = "${agentRunSource.date}-${shortCommit}";

  src = agentRunSource.src;

  cargoLock = agentRunSource.cargoLock."Cargo.lock";

  #doCheck = false;

  doInstallCheck = true;
  # nativeInstallCheckInputs = [ versionCheckHook ];

  meta = {
    description = "Centerized coding agent provider config and launcher for common coding agents";
    homepage = "https://git.jeffthecoder.xyz/public/agent-run";
    license = lib.licenses.wtfpl;
    mainProgram = "agent-run";
    platforms = lib.platforms.unix;
  };
}
