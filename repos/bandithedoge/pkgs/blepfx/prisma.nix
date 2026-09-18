{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "prisma";
  version = "126";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/prisma-x86_64-unknown-linux-gnu.zip";
    sha256 = "sha256-lDfGhHhOPrOpJxUSFhzUH1K95ORFbQoHlTZ+a8AW+s8=";
    stripRoot = false;
  };

  meta = {
    description = "FFT based 3-in-1 plugin";
    homepage = "https://fx.amee.ee/plugin/prisma/";
  };
})
