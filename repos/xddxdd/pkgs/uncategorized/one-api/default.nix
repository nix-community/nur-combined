{
  stdenv,
  lib,
  sources,
  autoPatchelfHook,
}:
stdenv.mkDerivation rec {
  pname = "one-api";
  inherit
    (
      if stdenv.isx86_64 then
        sources.one-api-amd64
      else if stdenv.isAarch64 then
        sources.one-api-arm64
      else
        throw "Unsupported architecture"
    )
    version
    src
    ;

  dontUnpack = true;

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    install -Dm755 $src $out/bin/one-api

    runHook postInstall
  '';

  meta = {
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenAI key management & redistribution system, using a single API for all LLMs";
    homepage = "https://openai.justsong.cn";
    license = lib.licenses.mit;
    platforms = [
      "x86_64-linux"
      "aarch64-linux"
    ];
    mainProgram = "one-api";
  };
}
