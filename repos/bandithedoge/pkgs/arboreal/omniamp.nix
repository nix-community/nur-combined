{ arboreal, fetchFromGitHub }:
arboreal.mkArboreal (finalAttrs: {
  pname = "omniamp";
  version = "1.0.2";
  src = fetchFromGitHub {
    owner = "ArborealAudio";
    repo = "OmniAmp";
    rev = finalAttrs.version;
    fetchSubmodules = true;
    hash = "sha256-tMcc2TBbv5AYejRkxFFgifjCZWXoGqRSFnBUYyeHw7g=";
  };

  meta = {
    homepage = "https://arborealaudio.com/plugins/omniamp";
    description = "All-in-one amplifier";
  };
})
