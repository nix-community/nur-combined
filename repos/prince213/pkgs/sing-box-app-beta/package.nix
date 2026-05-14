{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.23";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-vudc7b/5d033qynZ2RISuomkVprvb2pS9dzfoqwWjSY=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
