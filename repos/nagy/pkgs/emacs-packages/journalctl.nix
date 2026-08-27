{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "journalctl";
  version = "0-unstable-2026-08-27";

  src = fetchFromGitHub {
    owner = "WJCFerguson";
    repo = "journalctl";
    rev = "e0f284d39a43bb9d62de9862960a201c6e574f93";
    hash = "sha256-6a3A8cKhpYAMBD01oaVR/h4wOc8/eiGxw/ZZ54EZ5Dg=";
  };

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/WJCFerguson/journalctl";
    description = "Browse journald logs from Emacs";
    license = lib.licenses.gpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
