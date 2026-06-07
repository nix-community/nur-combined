{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.28";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-YazQcTg72QSX2HtKJWAXangbV9xl7evgtmpmCu1X9CU=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
