{ fetchurl, tonelib }:
tonelib.mkToneLib {
  pname = "tubewarmth";
  version = "2.0.1";
  src = fetchurl {
    url = "https://www.tonelib.net/download/ToneLib-TubeWarmth-amd64.deb";
    sha256 = "sha256-Rr+3foO57ZwofoE0aq6aQq2DWT6RZkcl9+1TOxdbYwU=";
  };

  product = "TubeWarmth";

  meta = {
    description = "The Vibrancy and Warmth of the Tube along with the Digital Precision and Clarity";
    homepage = "https://tonelib.net/tl-tubewarmth.html";
    mainProgram = "ToneLib-TubeWarmth";
  };
}
