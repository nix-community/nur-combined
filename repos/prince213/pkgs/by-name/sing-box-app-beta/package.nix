{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.50";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-Wa2/3HOc43ePlYRXs/3xOHiKTvlJP4u/xsmdKvlcSHI=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
