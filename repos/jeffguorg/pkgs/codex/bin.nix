{ lib
, stdenv
, autoPatchelfHook
, installShellFiles
, ncurses
, sources
, installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform
}:
let
  os = if stdenv.hostPlatform.isDarwin then
    "darwin"
  else if stdenv.hostPlatform.isLinux then
    "linux"
  else
    throw "Unsupported OS: ${stdenv.hostPlatform.system}";

  arch = if stdenv.hostPlatform.isAarch64 then
    "arm64"
  else if stdenv.hostPlatform.isx86_64 then
    "amd64"
  else
    throw "Unsupported architecture: ${stdenv.hostPlatform.system}";

  vendorTarget = if stdenv.hostPlatform.isDarwin then
    "${if stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64"}-apple-darwin"
  else
    "${if stdenv.hostPlatform.isAarch64 then "aarch64" else "x86_64"}-unknown-linux-musl";

  codex-bin = sources."codex-bin-${arch}-${os}";
in stdenv.mkDerivation {
  pname = "codex-bin";
  version = codex-bin.version;

  src = codex-bin.src;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [ ncurses ];

  nativeBuildInputs = [ installShellFiles ]
    ++ lib.optionals stdenv.hostPlatform.isLinux [ autoPatchelfHook ];

  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out
    cp -R vendor/${vendorTarget}/. $out/

    runHook postInstall
  '';

  postInstall = lib.optionalString installShellCompletions ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash 2>/dev/null) \
      --fish <($out/bin/codex completion fish 2>/dev/null) \
      --zsh <($out/bin/codex completion zsh 2>/dev/null)
  '';

  meta = with lib; {
    description = "OpenAI Codex binary release";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "codex";
  };
}
