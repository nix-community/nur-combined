{
  lib,
  rustPlatform,
  installShellFiles,
  sources,
  ...
}:
let
  agentRunSource = sources.agent-run;
  shortCommit = lib.substring 0 7 agentRunSource.version;
  sourceInfo = {
    BUILD_GIT_HASH = "${shortCommit}";
    BUILD_GIT_DIRTY = "false";
    BUILD_GIT_DATE = "${agentRunSource.date}";
  };
in
rustPlatform.buildRustPackage {
  pname = "agent-run";
  version = "${agentRunSource.date}-${shortCommit}";

  src = agentRunSource.src;

  cargoLock = agentRunSource.cargoLock."Cargo.lock";

  nativeBuildInputs = [
    installShellFiles
  ];
  inherit(sourceInfo) BUILD_GIT_HASH BUILD_GIT_DATE BUILD_GIT_DIRTY;

  postInstall = ''
    installShellCompletion --cmd agent-run \
      --bash <("$out/bin/agent-run" completion bash) \
      --zsh <("$out/bin/agent-run" completion zsh)
  '';

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
