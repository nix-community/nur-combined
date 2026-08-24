{ fetchFromGitHub, zl-audio }:
zl-audio.mkZl (finalAttrs: {
  pname = "zllmakeup";
  version = "0.2.7";
  src = fetchFromGitHub {
    owner = "ZL-Audio";
    repo = "ZLLMakeup";
    rev = "v${finalAttrs.version}";
    hash = "sha256-H6R5ZN005coDrf19nHpogAe+jY2/VA3B4w23gzYq+EM=";
    fetchSubmodules = true;
  };

  meta = {
    description = "loudness make-up plugin";
    homepage = "https://github.com/ZL-Audio/ZLLMakeup";
  };
})
