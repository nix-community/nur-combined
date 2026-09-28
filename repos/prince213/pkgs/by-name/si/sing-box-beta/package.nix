{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.9";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-2We28JxX2uVSdYPz7t7WnTNxFAH/k3REmCh1F7vIeFg=";
  };

  vendorHash = "sha256-JRhMBY6ayw5l12/SDsFviq8HAG9Gd3dSkmf9T0vh4gg=";
})
