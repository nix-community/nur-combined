{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "crunchrr";
  version = "128";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/crunchrr-x86_64-unknown-linux-gnu.zip";
    hash = "sha256-DzCHpXnz0mHs8n3+LoV4la9UboS/JSpt0EclNybfe1E=";
    stripRoot = false;
  };

  meta = {
    description = "Really simple to use effect that adds digital artifacts to your sounds";
    homepage = "https://fx.amee.ee/plugin/crunchrr/";
  };
})
