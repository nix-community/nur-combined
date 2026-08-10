{
  lib,
  sing-box,
  source,
}:
sing-box.overrideAttrs (_finalAttrs: previousAttrs: {
  pname = "sing-box-beta";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  vendorHash = "sha256-DF2eegNt5i/ymmJzef2vKQ9djbTUP3n8d5YxMqd8td0=";

  passthru = builtins.removeAttrs (previousAttrs.passthru or {}) ["updateScript"];

  meta =
    (previousAttrs.meta or {})
    // {
      changelog = "https://github.com/SagerNet/sing-box/releases/tag/${source.version}";
      maintainers = [
        {
          name = "mzwing";
        }
      ];
    };
})
