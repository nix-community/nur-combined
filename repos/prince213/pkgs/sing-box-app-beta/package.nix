{
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (previousAttrs: {
  pname = previousAttrs.pname + "-beta";
  version = "1.14.0-alpha.29";

  src = previousAttrs.src.overrideAttrs {
    hash = "sha256-LBm2gFINO3qQCvv2WNir4on9Z9sZQQ8sR4tuTRMMlyE=";
  };

  meta = sing-box-beta.meta // {
    platform = lib.platforms.darwin;
  };
})
