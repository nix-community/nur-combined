{ fetchzip, white-elephant-audio }:
white-elephant-audio.mkWea (finalAttrs: {
  pname = "richter";
  version = "2.3.0";
  src = fetchzip {
    url = "https://github.com/jd-13/wea-releases/releases/download/${finalAttrs.pname}-v${finalAttrs.version}/${finalAttrs.product}.v${finalAttrs.version}.zip";
    hash = "sha256-qN5NDLi0uFU9XhrGQrOblUrdcwX9qcfDQYEKtOiVK4o=";
    stripRoot = false;
  };

  product = "Richter";

  meta = {
    description = "Richter is an experimental tremolo/amplitude modulation tool with a pair of LFOs to modulate the audio directly, each with its own additional modulation LFO";
    homepage = "https://whiteelephantaudio.com/plugins/richter";
  };
})
