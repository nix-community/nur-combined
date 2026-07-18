{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.47";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-TMxN6XxEMZH/DUZxT5oBlpjKmg7tQEqTonXZpW69ZxY=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
