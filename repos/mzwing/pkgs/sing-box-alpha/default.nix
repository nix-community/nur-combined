{
  lib,
  sing-box,
  source,
}:
sing-box.overrideAttrs (_finalAttrs: previousAttrs: {
  pname = "sing-box-alpha";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  vendorHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";

  passthru = builtins.removeAttrs (previousAttrs.passthru or {}) ["updateScript"];

  meta = (previousAttrs.meta or {}) // {
    changelog = "https://github.com/SagerNet/sing-box/releases/tag/${source.version}";
  };
})
