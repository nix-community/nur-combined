{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.13";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-8iX4cN6wKPCd70r/82gVdSO/9YiGUqu8TOQHdgnW860=";
  };

  vendorHash = "sha256-DF2eegNt5i/ymmJzef2vKQ9djbTUP3n8d5YxMqd8td0=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
