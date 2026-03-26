{
  lib,
  fetchurl,
  pari,
  withStatic ? false,
}:

pari.overrideAttrs (
  finalAttrs: _:
  {
    version = "2.15.4";
    src = fetchurl {
      url = "https://pari.math.u-bordeaux.fr/pub/pari/OLD/${lib.versions.majorMinor finalAttrs.version}/pari-${finalAttrs.version}.tar.gz";
      hash = "sha256-w1Rb/uDG37QLd/tLurr5mdguYAabn20ovLbPAEyMXA8=";
    };
    installTargets = [
      "install"
    ]
    ++ lib.optionals withStatic [
      "install-lib-sta"
    ];
  }
)
