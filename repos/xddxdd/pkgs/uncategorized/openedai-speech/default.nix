{
  stdenv,
  lib,
  sources,
  python3,
  piper-tts,
  makeWrapper,
  ffmpeg,
}:
let
  pythonEnv = python3.withPackages (
    ps: with ps; [
      fastapi
      uvicorn
      loguru
      numpy
      pyyaml
      piper-tts
    ]
  );

  additionalPath = lib.makeBinPath [
    ffmpeg
    piper-tts
  ];
in
stdenv.mkDerivation (finalAttrs: {
  inherit (sources.openedai-speech) pname version src;

  nativeBuildInputs = [ makeWrapper ];

  postPatch = ''
    substituteInPlace speech.py \
      --replace-fail 'default = f"{basename}.default{ext}"' "default = f\"$out/opt/{basename}.default{ext}\""
  '';

  doCheck = true;
  checkPhase = ''
    runHook preCheck

    ${pythonEnv}/bin/python -c "import speech"

    runHook postCheck
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/opt

    cp -r *.py *.sh *.yaml $out/opt/

    makeWrapper ${pythonEnv}/bin/python $out/bin/${finalAttrs.pname} \
      --run "mkdir -p config" \
      --prefix PYTHONPATH : "$out/opt" \
      --suffix PATH : "${additionalPath}" \
      --add-flags "$out/opt/speech.py"

    makeWrapper $out/opt/download_voices_tts-1.sh $out/bin/download_voices_tts-1.sh \
      --suffix PATH : "${additionalPath}"

    runHook postInstall
  '';

  meta = {
    changelog = "https://github.com/matatonic/openedai-speech/releases/tag/${finalAttrs.version}";
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "OpenAI API compatible text to speech server using Coqui AI's xtts_v2 and/or piper tts as the backend";
    homepage = "https://github.com/matatonic/openedai-speech";
    license = with lib.licenses; [ agpl3Only ];
    broken = stdenv.isAarch64;
  };
})
