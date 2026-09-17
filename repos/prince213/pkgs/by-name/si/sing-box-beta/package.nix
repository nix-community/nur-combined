{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.5";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-kkufQiNSDyTv11cBHyvVZAC8H9mQQiOgRMhl5QWRlHw=";
  };

  vendorHash = "sha256-VrTW1hO7ord3uto4y3ECQB+Kb+8cbpLBJ4CWIxDYoNM=";
})
