{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.15.0-alpha.6";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-zKoHeCFT9yfCM25fSrXg4aUqr/EvHH2eBF19unR9muI=";
  };

  vendorHash = "sha256-IMz5BdB5jXiLTpoNS+MyEwFtVPJ/4Rpj7Mc7csfdkVY=";
})
