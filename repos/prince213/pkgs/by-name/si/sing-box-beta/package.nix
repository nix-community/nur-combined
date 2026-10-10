{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.11";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-SETjm9kMoo4M+EgrSXA36sLDQvHyPXRbPXyhDDds5mM=";
  };

  vendorHash = "sha256-O18+Y7wlcSUFRo54jC4Ogb8AtnPuLG7rPhzIDCC6sjU=";
})
