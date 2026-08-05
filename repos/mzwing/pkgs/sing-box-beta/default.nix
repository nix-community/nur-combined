{
  lib,
  sing-box,
  source,
}:
sing-box.overrideAttrs (_finalAttrs: previousAttrs: {
  pname = "sing-box-beta";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  vendorHash = "sha256-QDRLNatY0PHhM1GGusK/SOlCAK1le9Bf3t3Ns8rPG0Q=";

  passthru = builtins.removeAttrs (previousAttrs.passthru or {}) ["updateScript"];

  meta =
    (previousAttrs.meta or {})
    // {
      changelog = "https://github.com/SagerNet/sing-box/releases/tag/${source.version}";
    };
})
