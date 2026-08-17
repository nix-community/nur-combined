{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.17";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-7kn2UcCbea3v203U4knzbCKQECPCobIQXMy705RYucQ=";
  };

  vendorHash = "sha256-9Cv3WJG2C3yMk1d8UCLMIhgM5Q9dYAYp7A0F1LdZm/s=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
