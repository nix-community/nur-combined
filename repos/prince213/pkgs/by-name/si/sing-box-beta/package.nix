{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.2";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-KICV5xh9bOcdBkGAklIzSMXNYY/LxpbukgkW2vzYFuA=";
  };

  vendorHash = "sha256-c6dOQ5jLq/3k3P8cA3r8aq4oVa1lXovURQ9Izno7cgM=";
})
