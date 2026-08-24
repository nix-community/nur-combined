{ blepfx, fetchzip }:
blepfx.mkBlep (finalAttrs: {
  pname = "filtrr";
  version = "100";
  src = fetchzip {
    url = "https://github.com/blepfx/dist/releases/download/release-${finalAttrs.version}/filtrr-x86_64-unknown-linux-gnu.zip";
    sha256 = "sha256-k0jqtwClzW/oNtKR2/nsQNFCbt6J0Lp3dmAf2X09UOU=";
    stripRoot = false;
  };

  meta = {
    description = "Nonlinear ladder filter that is capable of producing a large variety of sounds";
    homepage = "https://fx.amee.ee/plugin/filtrr/";
  };
})
