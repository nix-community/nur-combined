{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.10";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-7e+8EXtZN3x/vrgOzxu7ze+2EjTQLWnhHpDcjqLTHc0=";
  };

  vendorHash = "sha256-V3brKNtqm6wOkptf13rVb9acTQ1tj6lgnSTacTpvk/I=";
})
