{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-rc.1";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-SMFPB3ab2Y/Aakbgnaz1iDp0ZF+iHE3BOvoRojII9Cc=";
  };

  vendorHash = "sha256-ea9oaMryf4qEc3bjkEzFN+Rt8djnhM8AqmKUG65xCVc=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
