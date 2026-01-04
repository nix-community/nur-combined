{
  stdenv,
  lib,
  sources,
  python3,
  makeWrapper,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      edge-tts
      emoji
      flask
      gevent
      python-dotenv
    ]
  );
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.openai-edge-tts) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    pushd app
    ${lib.getExe pythonEnv} -c "import server"
    popd

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin

    cp -r app $out/opt

    makeWrapper ${lib.getExe pythonEnv} $out/bin/${finalAttrs.pname} \
      --prefix PYTHONPATH : "$out/opt" \
      --add-flags "$out/opt/server.py"

    runHook postInstall
  '';

  meta = {
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Text-to-speech API endpoint compatible with OpenAI's TTS API endpoint, using Microsoft Edge TTS to generate speech for free locally";
    homepage = "https://tts.travisvn.com/";
    license = with lib.licenses; [ gpl3Only ];
  };
})
