{
  lib,
  sing-box,
  source,
}:
sing-box.overrideAttrs (_finalAttrs: previousAttrs: {
  pname = "sing-box-beta";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  vendorHash = "sha256-Oxcl4YvPEQFhsljUFqQ9GJRkOz6OHlfuN3tA7eLeB8Y=";

  passthru = builtins.removeAttrs (previousAttrs.passthru or {}) ["updateScript"];

  meta =
    (previousAttrs.meta or {})
    // {
      changelog = "https://github.com/SagerNet/sing-box/releases/tag/${source.version}";
    };
})
