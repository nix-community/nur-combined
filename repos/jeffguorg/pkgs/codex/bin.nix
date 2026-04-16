{ lib
, stdenv
, fetchurl
, autoPatchelfHook
, installShellFiles
, makeBinaryWrapper
, sources
, zstd
, libcap
, zlib
, openssl
, ripgrep
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

  codex-bin =  sources."codex-bin-${arch}-${os}";
in stdenv.mkDerivation rec {
  pname = codex-bin.pname;
  version = codex-bin.version;

  src = codex-bin.src;

  buildInputs = lib.optionals stdenv.hostPlatform.isLinux [
    libcap
    zlib
    openssl
    stdenv.cc.cc.lib
  ];

  nativeBuildInputs = [
    zstd
    autoPatchelfHook
    installShellFiles
    makeBinaryWrapper
  ];

  dontConfigure = true;
  dontBuild = true;
  dontAutoPatchelf = true;

  unpackPhase = ''
    runHook preUnpack

    mkdir source
    cd source

    zstd -d --stdout "$src" > codex
    chmod +x codex

    runHook postUnpack
  '';

  installPhase = ''
    runHook preInstall

    install -Dm755 codex $out/bin/codex
  '' + (if stdenv.hostPlatform.isLinux then ''
    autoPatchelf $out/bin/codex
  '' else "") + ''

    runHook postInstall
  '';

  postFixup = ''
    wrapProgram $out/bin/codex --prefix PATH : ${lib.makeBinPath [ ripgrep ]}
  '';

  postInstall = lib.optionalString installShellCompletions ''
    installShellCompletion --cmd codex \
      --bash <($out/bin/codex completion bash) \
      --fish <($out/bin/codex completion fish) \
      --zsh <($out/bin/codex completion zsh)
  '';

  meta = with lib; {
    description = "OpenAI Codex binary release";
    homepage = "https://github.com/openai/codex";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "codex";
  };
}
