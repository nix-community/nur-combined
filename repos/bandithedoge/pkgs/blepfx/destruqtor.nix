{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "destruqtor";
  version = "100";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/destruqtor-x86_64-unknown-linux-gnu.zip";
    sha256 = "sha256-9N9NW7s3IeCb1a1Q4JadmAmojRXS/rFZGYVAJr8Y7lg=";
    stripRoot = false;
  };

  meta = {
    description = "Companding distortion/saturation/exciter plugin";
    homepage = "https://fx.amee.ee/plugin/destruqtor/";
  };
})
