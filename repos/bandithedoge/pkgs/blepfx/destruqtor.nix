{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "destruqtor";
  version = "126";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/destruqtor-x86_64-unknown-linux-gnu.zip";
    sha256 = "sha256-a9EezIXL2ZxDEHZiGhAHTTqBThWWABBQ30Y0q6nWLco=";
    stripRoot = false;
  };

  meta = {
    description = "Companding distortion/saturation/exciter plugin";
    homepage = "https://fx.amee.ee/plugin/destruqtor/";
  };
})
