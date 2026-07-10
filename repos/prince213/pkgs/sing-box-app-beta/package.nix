{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.42";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-LZSIZRIh/WkerK69Mht89eCA/yTbmW8NOaGAd5aVJ4Y=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
