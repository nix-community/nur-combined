{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.39";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-i4RB1UFRFQ6RB9YR4GU2D38x9hyxGELlO7jrJmJYw+s=";
  };

  meta = sing-box-beta.meta // {
    platforms = lib.platforms.darwin;
  };
})
