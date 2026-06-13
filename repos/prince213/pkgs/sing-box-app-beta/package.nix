{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.30";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-FYu+7wOG7JFJofr948YzrqGQtRkABMEIM9oDA6rTNMk=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
