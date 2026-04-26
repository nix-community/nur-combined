{
  fetchurl,
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.18";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-/11SKsnbzEJO67Hyl0YRV3882NnTKrz4a5oGH9s5CRk=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
