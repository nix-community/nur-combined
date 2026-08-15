{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.15";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-fUaq2tyC2kTDveKhRMB+TQMZLL515MqkyK8mS85U7kI=";
  };

  vendorHash = "sha256-4MtT1e8OQBo7kp0pZ7AnQwru3CRGdcSdLSrb3jGUxK0=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
