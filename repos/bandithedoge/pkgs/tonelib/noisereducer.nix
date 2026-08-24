{ fetchurl, tonelib }:
tonelib.mkToneLib {
  pname = "noisereducer";
  version = "2.0.2";
  src = fetchurl {
    url = "https://www.tonelib.net/download/ToneLib-NoiseReducer-amd64.deb";
    sha256 = "sha256-R+JXoc6waKGPMaghlJ8BkLumDcjC7Oq0jx8tFjAKegE=";
  };

  product = "NoiseReducer";

  meta = {
    description = "Powerful, yet simple two-unit rack effect on guard of your mix clarity";
    homepage = "https://tonelib.net/tl-noisereducer.html";
    mainProgram = "ToneLib-NoiseReducer";
  };
}
