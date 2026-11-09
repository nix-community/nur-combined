{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild (finalAttrs: {
  pname = "journalctl";
  version = "1.4";

  src = fetchFromGitHub {
    owner = "WJCFerguson";
    repo = "journalctl";
    tag = "v${finalAttrs.version}";
    hash = "sha256-rmKLsNs5tBiAW/4jUUciYqMYQveTzS6IWFoSZpQ2bgs=";
  };

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/WJCFerguson/journalctl";
    description = "Browse journald logs from Emacs";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
})
