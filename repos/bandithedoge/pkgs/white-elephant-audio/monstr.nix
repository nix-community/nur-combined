{ fetchzip, white-elephant-audio }:
white-elephant-audio.mkWea (finalAttrs: {
  pname = "monstr";
  version = "2.1.3";
  src = fetchzip {
    url = "https://github.com/jd-13/wea-releases/releases/download/${finalAttrs.pname}-v${finalAttrs.version}/${finalAttrs.product}.v${finalAttrs.version}.zip";
    hash = "sha256-Ncs2d0yUD/gZ+ZYCmIyDBhrQk/BY+32n3zuXntKmqV0=";
    stripRoot = false;
  };

  product = "MONSTR";

  meta = {
    description = "MONSTR provides up to six bands of stereo width control to correct mix issues or use for creative effect";
    homepage = "https://whiteelephantaudio.com/plugins/monstr";
  };
})
