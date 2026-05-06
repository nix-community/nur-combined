{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.21";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-cqC3COv6c0nMej7D3a817XioFiHeohdr1lWUnI2nJ9o=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
