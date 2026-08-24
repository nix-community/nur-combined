{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "crunchrr";
  version = "100";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/crunchrr-x86_64-unknown-linux-gnu.zip";
    hash = "sha256-8etQEJI4azfc80pR+areBdrLgbWcPb5S5p3TyhOFY2E=";
    stripRoot = false;
  };

  meta = {
    description = "Really simple to use effect that adds digital artifacts to your sounds";
    homepage = "https://fx.amee.ee/plugin/crunchrr/";
  };
})
