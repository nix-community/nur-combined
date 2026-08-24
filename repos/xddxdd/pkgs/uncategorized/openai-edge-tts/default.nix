{
  fetchFromGitHub,
  nix-update-script,
  stdenv,
  lib,
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
  pname = "openai-edge-tts";
  version = "2.0.0-unstable-2025-07-01";
  src = fetchFromGitHub {
    owner = "travisvn";
    repo = "openai-edge-tts";
    rev = "edaed2afd2cdedcc4648380185d8d7cf7a1eee97";
    hash = "sha256-CAU48qeRffUZLpZXDFaPCK1muB3w38VpDD/yAaGBLes=";
  };
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

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version"
      "branch"
    ];
  };
  meta = {
    mainProgram = finalAttrs.pname;
    maintainers = with lib.maintainers; [ xddxdd ];
    description = "Text-to-speech API endpoint compatible with OpenAI's TTS API endpoint, using Microsoft Edge TTS to generate speech for free locally";
    homepage = "https://tts.travisvn.com/";
    license = with lib.licenses; [ gpl3Only ];
  };
})
