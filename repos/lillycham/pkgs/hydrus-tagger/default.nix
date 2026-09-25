{
  lib,
  stdenv,
  fetchFromGitHub,
  fetchurl,
  ffmpeg-headless,
  linkFarm,
  makeWrapper,
  python3,
  swift,
}:
let
  modelRev = "7f6b584d0bd3f55c4531f14ba3d4761b2bccdc0f";
  hf = file: "https://huggingface.co/SmilingWolf/wd-vit-tagger-v3/resolve/${modelRev}/${file}";

  model = linkFarm "wd-vit-tagger-v3" {
    "model.onnx" = fetchurl {
      url = hf "model.onnx";
      hash = "sha256-NfI2k2ILZo9NU/08Yr9l5Ar3ObxSx+sPvEkli1jQZbY=";
    };
    "selected_tags.csv" = fetchurl {
      url = hf "selected_tags.csv";
      hash = "sha256-KYYz2U0AMdIIHAiT8pyC6rfw3wCwhIO6jynR6XlEEhc=";
    };
  };

  python = python3.withPackages (ps: [
    ps.numpy
    ps.onnxruntime
    ps.pillow
    ps.send2trash
  ]);
in
stdenv.mkDerivation {
  pname = "hydrus-tagger";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "lillycham";
    repo = "hydrus-tagger";
    rev = "558b3690996a62856adaaa0fb75457462b98f917";
    hash = "sha256-n16xxha2MTbd2hE67+mI5RoMqga20IFjG3l/0fji4/o=";
  };

  nativeBuildInputs = [
    makeWrapper
    swift
  ];

  buildPhase = ''
    runHook preBuild
    swiftc -O media.swift -o hydrus-tagger-media
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    install -Dm755 hydrus-tagger-media $out/libexec/hydrus-tagger-media
    install -Dm644 hydrus_tagger.py $out/libexec/hydrus_tagger.py
    makeWrapper ${python}/bin/python3 $out/bin/hydrus-tagger \
      --add-flags "-u $out/libexec/hydrus_tagger.py" \
      --set HYDRUS_TAGGER_MODEL ${model} \
      --set HYDRUS_TAGGER_MEDIA $out/libexec/hydrus-tagger-media \
      --prefix PATH : ${lib.makeBinPath [ ffmpeg-headless ]}
    runHook postInstall
  '';

  meta = {
    description = "Import images into hydrus with WD tagger and OCR tags";
    homepage = "https://github.com/lillycham/hydrus-tagger";
    license = lib.licenses.unlicense;
    platforms = lib.platforms.darwin;
    mainProgram = "hydrus-tagger";
  };
}
