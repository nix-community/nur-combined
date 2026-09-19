{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "prisma";
  version = "128";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/prisma-x86_64-unknown-linux-gnu.zip";
    sha256 = "sha256-Fv/U2o3avE9jj0dHaw6JhO3djgVo40qQhlfSIMPGeog=";
    stripRoot = false;
  };

  meta = {
    description = "FFT based 3-in-1 plugin";
    homepage = "https://fx.amee.ee/plugin/prisma/";
  };
})
