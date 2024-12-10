{
  callPackage,
  stdenv,
  fetchurl,
  makeWrapper,
}:
let
  deepspeech = callPackage ./default.nix { };
  inherit (deepspeech) version;

  model-en = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/deepspeech-${version}-models.pbmm";
    hash = "sha256-6+m09kvaNZGs1yPCdinxAdG7HsSHcw2fiCvP4DIURi0=";
  };

  model-zh = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/deepspeech-${version}-models-zh-CN.pbmm";
    hash = "sha256-fQQ1HVUmKQqh0YGV+S1/XrhMDuq0N8gE3SQcZ989PdE=";
  };

  scorer-en = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/deepspeech-${version}-models.scorer";
    hash = "sha256-0M+SarnKtUqKfXAAO5MbLWLr2RBe05LR7JyEACmGd5k=";
  };

  scorer-zh = fetchurl {
    url = "https://github.com/mozilla/DeepSpeech/releases/download/v${version}/deepspeech-${version}-models-zh-CN.scorer";
    hash = "sha256-JofZaPRhiVBNm57cD5FPa0s5xNlMc/dbamwYDTPzAkA=";
  };
in
stdenv.mkDerivation rec {
  pname = "deepspeech";
  inherit version;

  buildInputs = [ makeWrapper ];

  dontUnpack = true;
  postInstall = ''
    mkdir -p $out/bin

    makeWrapper ${deepspeech}/bin/deepspeech $out/bin/deepspeech-en \
      --add-flags "--model" \
      --add-flags "${model-en}" \
      --add-flags "--scorer" \
      --add-flags "${scorer-en}"

    makeWrapper ${deepspeech}/bin/deepspeech $out/bin/deepspeech-zh \
      --add-flags "--model" \
      --add-flags "${model-zh}" \
      --add-flags "--scorer" \
      --add-flags "${scorer-zh}"
  '';

  inherit (deepspeech) meta;
}
