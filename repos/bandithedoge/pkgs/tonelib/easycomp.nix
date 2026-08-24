{ fetchurl, tonelib }:
tonelib.mkToneLib {
  pname = "easycomp";
  version = "2.2.1";
  src = fetchurl {
    url = "https://tonelib.net/download/ToneLib-EasyComp-amd64.deb";
    sha256 = "sha256-0ux+COXnLCk68eTEnNaCmvyuy4HJj4ggdXBpVLsguTQ=";
  };

  product = "EasyComp";

  meta = {
    description = "Powerful Compressor without any Complexity";
    homepage = "https://tonelib.net/plugins/tl-easycomp.html";
    mainProgram = "ToneLib-EasyComp";
  };
}
