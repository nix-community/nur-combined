{
  lib,
  fetchFromGitHub,
  mkTclDerivation,
  tcl,
  autoreconfHook,
  nix-update-script,
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

  nativeBuildInputs = [ autoreconfHook ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Syslog interface for Tcl";
    homepage = "https://github.com/mxmanghi/tcl-syslog";
    changelog = "https://github.com/mxmanghi/tcl-syslog/blob/${finalAttrs.src.tag}/ChangeLog";
    license = lib.licenses.gpl3Plus;
    platforms = lib.platforms.unix;
  };
})
