{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.4";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-dFMxkJ8PNPctMS/E5L3G/pOM8jOtPPRACaGG7R3wT8g=";
  };

  vendorHash = "sha256-AbTfAciw4hm5o7ySSuw330kVtrw1DfaAyqYPR5E4380=";
})
