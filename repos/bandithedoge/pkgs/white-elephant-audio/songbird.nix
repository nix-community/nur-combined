{ fetchzip, white-elephant-audio }:
white-elephant-audio.mkWea (finalAttrs: {
  pname = "songbird";
  version = "2.3.0";
  src = fetchzip {
    url = "https://github.com/jd-13/wea-releases/releases/download/${finalAttrs.pname}-v${finalAttrs.version}/${finalAttrs.product}.v${finalAttrs.version}.zip";
    hash = "sha256-3/foGvHwr5bv22+G3Ws3PYIZabbf2eBvU6B8QnsPBzM=";
    stripRoot = false;
  };

  product = "Songbird";

  meta = {
    description = "Songbird adds subtle textures or expressive vowel sounds to any instrument using a pair of formant filter banks and the built in modulation options";
    homepage = "https://whiteelephantaudio.com/plugins/songbird";
  };
})
