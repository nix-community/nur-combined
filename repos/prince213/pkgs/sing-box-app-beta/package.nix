{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.32";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-73zI+xPOQVogFT5CnCjnPxwcMkG2istTvah+0siEAGs=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
