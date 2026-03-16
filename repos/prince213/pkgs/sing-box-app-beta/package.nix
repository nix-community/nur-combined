{
  fetchurl,
  lib,
  sing-box-app,
  sing-box-beta,
}:

sing-box-app.overrideAttrs (
  finalAttrs: previousAttrs: {
    pname = previousAttrs.pname + "-beta";
    version = "1.14.0-alpha.3";

    src = fetchurl {
      url = "https://github.com/SagerNet/sing-box/releases/download/v${finalAttrs.version}/SFM-${finalAttrs.version}-Universal.pkg";
      hash = "sha256-dQnuWRBrSEcos6QuhKvApxzCObTPq7DIZpaJsDgaQWo=";
    };

    meta = sing-box-beta.meta // {
      platform = lib.platforms.darwin;
    };
  }
)
