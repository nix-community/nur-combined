{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "prisma";
  version = "100";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/prisma-x86_64-unknown-linux-gnu.zip";
    sha256 = "sha256-K7BcR1a7iv1JuRfNdR4USij+37nzWC/oglEWKkNNN5Y=";
    stripRoot = false;
  };

  meta = {
    description = "FFT based 3-in-1 plugin";
    homepage = "https://fx.amee.ee/plugin/prisma/";
  };
})
