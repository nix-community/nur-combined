{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.31";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-nwkMuL9f6DYw7vVwq1KbflenArzctfxEnVUL6wJAISw=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
