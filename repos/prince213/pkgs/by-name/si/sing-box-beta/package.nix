{
  sing-box,
}:

sing-box.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.10";
  __structuredAttrs = true;

  src = previousAttrs.src.override {
    hash = "sha256-dEoQAj7VOi2T9j2kEkscmzv/wOVBYZaWD3aCiilK9rs=";
  };

  vendorHash = "sha256-l5vNu/JhZRLvXyD2sWPS4qVaTSgmzDQadsNwwF4Ucnw=";

  tags = previousAttrs.tags ++ [
    "with_cloudflared"
    "with_usbip"
    "with_openvpn"
    "with_openconnect"
  ];
})
