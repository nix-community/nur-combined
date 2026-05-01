{ lib
, pkgs
, stdenv
, fetchurl
, autoPatchelfHook
, makeBinaryWrapper
, installShellCompletions ? stdenv.buildPlatform.canExecute stdenv.hostPlatform
, sources
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

  claude-code-bin =  sources."claude-code-bin-${arch}-${os}";
in stdenv.mkDerivation rec {
  pname = "claude-code-bin";
  version = claude-code-bin.version;

  src = claude-code-bin.src;

  nativeBuildInputs = [
    #autoPatchelfHook
    makeBinaryWrapper
  ];

  dontUnpack = true;
  dontConfigure = true;
  dontBuild = true;
  dontStrip = true;

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/claude

    runHook postInstall
  '';

  meta = with lib; {
    description = "Claude Code binary release";
    homepage = "https://github.com/anthropics/claude-code";
    license = licenses.asl20;
    platforms = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    mainProgram = "claude";
  };
}
