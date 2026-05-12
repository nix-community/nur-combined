{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.22";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-EIAtDqA8xi+aAYlEEZurs7KUFF1UrlJBKOBYa6QIhuU=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
