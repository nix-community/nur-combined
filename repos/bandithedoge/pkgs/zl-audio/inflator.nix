{ fetchFromGitHub, zl-audio }:
zl-audio.mkZl (finalAttrs: {
  pname = "zlinflator";
  version = "0.3.0";
  src = fetchFromGitHub {
    owner = "ZL-Audio";
    repo = "ZLInflator";
    rev = "${finalAttrs.version}";
    hash = "sha256-HR2zZYEZvAIZCM05VAcDbCbyp16uma3v8+U66XgW/RY=";
    fetchSubmodules = true;
  };

  meta = {
    description = "distortion/saturation plugin";
    homepage = "https://github.com/ZL-Audio/ZLInflator";
  };
})
