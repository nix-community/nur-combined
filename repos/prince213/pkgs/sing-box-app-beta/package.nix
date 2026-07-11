{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.43";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-vVB4GnTHoUhqxWlLo61zRmQaYn1K7vZ2BhYRXuGFrBQ=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
