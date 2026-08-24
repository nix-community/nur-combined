{ fetchzip, white-elephant-audio }:
white-elephant-audio.mkWea (finalAttrs: {
  pname = "carve";
  version = "2.6.1";
  src = fetchzip {
    url = "https://github.com/jd-13/wea-releases/releases/download/${finalAttrs.pname}-v${finalAttrs.version}/${finalAttrs.product}.v${finalAttrs.version}.zip";
    hash = "sha256-k/E1m2drSWCQ5a5MKt+d3wxDpxTMJ6GlbowV80DfWU0=";
    stripRoot = false;
  };

  product = "Carve";

  meta = {
    description = "Carve is an experimental wave shaping distortion, with a pair of distortions, flexible routing, and multiple algorithms to choose from";
    homepage = "https://whiteelephantaudio.com/plugins/carve";
  };
})
