{
  lib,
  sources,
  stdenv,
  autoPatchelfHook,
  versionCheckHook,
}:
stdenv.mkDerivation (finalAttrs: {
  pname = "cliproxyapi";
  inherit
    (
      if stdenv.isx86_64 then
        sources.cliproxyapi-amd64
      else if stdenv.isAarch64 then
        sources.cliproxyapi-arm64
      else
        throw "Unsupported architecture"
    )
    version
    src
    ;

  nativeBuildInputs = [
    autoPatchelfHook
    versionCheckHook
  ];

  versionCheckProgramArg = [ "--version" ];

  sourceRoot = ".";

  installPhase = ''
    runHook preInstall

    install -Dm755 cli-proxy-api $out/bin/cli-proxy-api

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Wrap Gemini CLI, Antigravity, ChatGPT Codex, Claude Code, Qwen Code, iFlow as an OpenAI/Gemini/Claude/Codex compatible API service";
    homepage = "https://github.com/router-for-me/CLIProxyAPI";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "cli-proxy-api";
  };
})
