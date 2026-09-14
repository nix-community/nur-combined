{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.3";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-7Mq+F8zN22Io9nyWokXa0G+qGxyUYbgbImtPzuyig8o=";
  };

  vendorHash = "sha256-rVmap4g2HOXYJDw/2WYvxSsM/CQ5jKL4xIi375PGW7s=";
})
