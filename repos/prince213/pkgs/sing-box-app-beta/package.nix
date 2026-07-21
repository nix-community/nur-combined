{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.48";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-KEjDhcFxKWI3QwTJomxQAf6ZEIm1p+PZduM9eDgiyfs=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
