{ fetchurl, tonelib }:
tonelib.mkToneLib {
  pname = "bassdrive";
  version = "2.1.0";
  src = fetchurl {
    url = "https://www.tonelib.net/download/ToneLib-BassDrive-amd64.deb";
    sha256 = "sha256-Yqo3nbW6u8pp+oD3uCiqkU+rIv7TN0NHuxAdiC/Apyw=";
  };

  product = "BassDrive";

  meta = {
    description = "Full Power of the Legendary Drive Pedal for the Highest String Gauges";
    homepage = "https://tonelib.net/tl-bassdrive.html";
    mainProgram = "ToneLib-BassDrive";
  };
}
