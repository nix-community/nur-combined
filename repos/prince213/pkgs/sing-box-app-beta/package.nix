{
  fetchurl,
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.19";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-JBkiN2nm2q9WBVhMyIevkipnWTiU9VF8S52CT6OapBM=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
