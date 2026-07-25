{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-beta.2";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-lWGMYQJEhkuKD8qgIzgtf63n51L0No25/e9Z4ePVnFQ=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
