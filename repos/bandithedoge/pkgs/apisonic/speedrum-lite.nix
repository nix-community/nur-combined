{ apisonic, fetchzip }:
apisonic.mkApisonic (finalAttrs: {
  pname = "speedrum-lite";
  version = "1.0.3";
  src = fetchzip {
    url = "https://github.com/apisonic/SL-bin/releases/download/v${finalAttrs.version}/speedrum-lite-v${finalAttrs.version}.zip";
    hash = "sha256-uen5+47KQHgxSM8Zx2UnetnGmh1J/j3koB0kdpe5btk=";
    stripRoot = false;
  };

  product = "SpeedrumLite";

  meta = {
    homepage = "https://www.apisonic-audio.com/freeware.html";
    description = "A 'simple' drum - percussion MPC style sampler";
  };
})
