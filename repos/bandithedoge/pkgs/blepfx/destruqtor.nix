{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "destruqtor";
  version = "128";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/destruqtor-x86_64-unknown-linux-gnu.zip";
    sha256 = "sha256-RJCtWV55vW6/IfoO2KfvVJ9cW4rlO89usFxNpq7fb+M=";
    stripRoot = false;
  };

  meta = {
    description = "Companding distortion/saturation/exciter plugin";
    homepage = "https://fx.amee.ee/plugin/destruqtor/";
  };
})
