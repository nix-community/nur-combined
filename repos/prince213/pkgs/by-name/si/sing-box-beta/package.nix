{
  sing-box,

  # buildInputs
  cronet-go-beta,
}:

(sing-box.override { cronet-go = cronet-go-beta; }).overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.14";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-roTsxlazxYsFqSZoIEWVJnu7XnVEJ/1seva/gUgzpu4=";
  };

  vendorHash = "sha256-GWVDppwDUL/3DwdOvbzIH4IiVUX50xEB8g6WpErsPc8=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
