{
  lib,
  fetchFromGitHub,
  mkTclDerivation,
  tcl,
}:

mkTclDerivation (finalAttrs: {
  pname = "tcl-syslog";
  version = "2.0.2";

  src = fetchFromGitHub {
    owner = "mxmanghi";
    repo = "tcl-syslog";
    tag = "v${finalAttrs.version}";
    hash = "sha256-Wgip+153xdrinTZSiSzsChdLqXj3sACTrBKwHb60esQ=";
  };

  meta = {
    homepage = "https://github.com/mxmanghi/tcl-syslog";
    description = "Syslog interface for Tcl";
    license = lib.licenses.gpl3Plus;
  };
})
