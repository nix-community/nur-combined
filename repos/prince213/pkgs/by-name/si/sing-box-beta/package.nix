{
  sing-box,
}:

sing-box.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.5";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-9s6C7F5LVGKkr65FIuUM32hkUbXUlC4MGINNSBdWykc=";
  };

  vendorHash = "sha256-djkEuzNVT9MRFHm2F6O+wBqEZd5LXH0kdZqd2qSy8iQ=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
