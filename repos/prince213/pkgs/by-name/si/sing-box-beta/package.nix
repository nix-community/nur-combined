{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.8";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-g456S8Pw9GYm0E48fNUAg840r+MinxKTpbcIzQKhniA=";
  };

  vendorHash = "sha256-1xP8RLU0/ZP6j8DbNiPaI0Pnw6PpBNp2hsTTE4U+PWQ=";
})
