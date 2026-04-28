{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.20";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-eEdBcbvReYWpDZ4FiwBujVXA1vfj5r7/P5EhKyv2bHE=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
