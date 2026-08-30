{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-rc.4";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-9ybFSCPCGCvanWgRjLFtb/tejz/gSlo/R9E754JDSDM=";
  };

  vendorHash = "sha256-RWCCScJVaKTmNrBiGips6QWz6EFTBXXMNsi+UqNvnjU=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
