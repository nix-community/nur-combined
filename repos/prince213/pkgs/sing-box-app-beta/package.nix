{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.33";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-aC2fQhOIOzhun9AutDOv04+tbcH6jPkGhzkwXPv9jaQ=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
