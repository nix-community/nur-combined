{ arboreal, fetchFromGitHub }:
arboreal.mkArboreal (finalAttrs: {
  pname = "pimax";
  version = "1.1.3";
  src = fetchFromGitHub {
    owner = "ArborealAudio";
    repo = "PiMax";
    rev = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-nr63yikQUvbYtM3ADMmSNTm6tjSQ06anV5gabP6RQrQ=";
  };

  cmakeFlags = [
    "-DFETCHCONTENT_SOURCE_DIR_JUCE=${
      fetchFromGitHub {
        owner = "ArborealAudio";
        repo = "JUCE";
        rev = "730669c40166d49b3d2c9d6048cd0493cef998f8";
        hash = "sha256-oKKBptJ5jSJ5jThaBTpvFhgMzuSwWC7ZGGVJPuP+o7M=";
      }
    }"
    "-DFETCHCONTENT_SOURCE_DIR_CLAP-JUCE-EXTENSIONS=${
      fetchFromGitHub {
        owner = "free-audio";
        repo = "clap-juce-extensions";
        rev = "8d0754f5d6ca1e95bc207b7743c04ebd7dc17e88";
        fetchSubmodules = true;
        hash = "sha256-gb0uK3pkTgINUC4IhmEC/nEKvuBxyFJZyPV59hpzXcg=";
      }
    }"
    "-DFETCHCONTENT_SOURCE_DIR_PFFFT=${
      fetchFromGitHub {
        owner = "marton78";
        repo = "pffft";
        rev = "e0bf595c98ded55cc457a371c1b29c8cab552628";
        hash = "sha256-6NjpHkVxWFrriY55Btq//tR1YOYAdm0Bsp5ue3RWXlE=";
      }
    }"
  ];

  meta = {
    homepage = "https://arborealaudio.com/plugins/pimax";
    description = "Make It Loud";
  };
})
