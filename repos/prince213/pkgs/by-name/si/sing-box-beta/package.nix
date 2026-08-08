{
  sing-box,
}:

sing-box.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.9";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-qUP0r6TQnb/ae+gfIwdnUtbWiYi9sNdK3Prh/qC3wT4=";
  };

  vendorHash = "sha256-Oxcl4YvPEQFhsljUFqQ9GJRkOz6OHlfuN3tA7eLeB8Y=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
