{
  lib,
  sing-box,
  source,
}:
sing-box.overrideAttrs (_finalAttrs: previousAttrs: {
  pname = "sing-box-alpha";
  version = lib.removePrefix "v" source.version;
  inherit (source) src;

  vendorHash = "sha256-4F3p5ENJcf0/c9C5aYaqJXhprq9sD+f156YZOsuSlNk=";

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
