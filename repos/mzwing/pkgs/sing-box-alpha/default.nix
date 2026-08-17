{
  lib,
  sing-box,
  source,
}:
sing-box.overrideAttrs (_finalAttrs: previousAttrs: {
  pname = "sing-box-alpha";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  vendorHash = "sha256-9Cv3WJG2C3yMk1d8UCLMIhgM5Q9dYAYp7A0F1LdZm/s=";

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
