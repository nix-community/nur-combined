{ fetchFromGitHub, zl-audio }:
zl-audio.mkZl (finalAttrs: {
  pname = "zllmatch";
  version = "0.2.4";
  src = fetchFromGitHub {
    owner = "ZL-Audio";
    repo = "ZLLMatch";
    rev = "v${finalAttrs.version}";
    hash = "sha256-HswX1bWg1Rej+em21N1H3G1TVmeXY+tq0ib9OKNlTN4=";
    fetchSubmodules = true;
  };

  meta = {
    description = "loudness matching plugin";
    homepage = "https://github.com/ZL-Audio/ZLLMatch";
  };
})
