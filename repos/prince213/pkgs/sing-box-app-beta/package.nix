{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.24";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-UEhlyW32ofGXmn9D6EnOWdYl6CqgHKwYLyMd1rGVbJo=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
