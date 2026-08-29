{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-rc.2";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-c4bEPaWKfElkSYgzFYvEx1YKH58Lz+jO5CQOsqTvxzU=";
  };

  vendorHash = "sha256-mVmqVVDFWH8sdqV9Zd5Y9hFQCk7nPtvRhJ20/me1Fuw=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
