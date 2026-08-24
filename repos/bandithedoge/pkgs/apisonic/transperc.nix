{ apisonic, fetchzip }:
apisonic.mkApisonic (finalAttrs: {
  pname = "transperc";
  version = "1.0.0";
  src = fetchzip {
    url = "https://github.com/apisonic/tr-one/releases/download/v${finalAttrs.version}/transperc.zip";
    hash = "sha256-GJ8QsskeemYNuwwd6+VvtUKgghdhQCt1dVSkh7UNZo4=";
    stripRoot = false;
  };
  sourceRoot = "source/transperc/linux";

  product = "Transperc";

  meta = {
    homepage = "https://www.apisonic-audio.com/freeware.html";
    description = "Transient processor (shaper) created mainly for percussive material, but can be used on any type of sound";
  };
})
