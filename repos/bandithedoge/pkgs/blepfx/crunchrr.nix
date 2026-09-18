{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "crunchrr";
  version = "126";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/crunchrr-x86_64-unknown-linux-gnu.zip";
    hash = "sha256-PmGLRjYxhcKSXaHm4EUDjydjrV80KsFSxCr1h05NfbY=";
    stripRoot = false;
  };

  meta = {
    description = "Really simple to use effect that adds digital artifacts to your sounds";
    homepage = "https://fx.amee.ee/plugin/crunchrr/";
  };
})
