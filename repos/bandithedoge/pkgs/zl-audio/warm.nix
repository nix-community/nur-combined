{ fetchFromGitHub, zl-audio }:
zl-audio.mkZl (finalAttrs: {
  pname = "zlwarm";
  version = "0.2.1";
  src = fetchFromGitHub {
    owner = "ZL-Audio";
    repo = "ZLWarm";
    rev = finalAttrs.version;
    hash = "sha256-+koLt4HZKbDvveMD9HrN+/4fq9H+Y4irCjcZZGBL59s=";
    fetchSubmodules = true;
  };

  meta = {
    description = "distortion/saturation plugin";
    homepage = "https://github.com/ZL-Audio/ZLWarm";
  };
})
