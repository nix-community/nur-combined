{
  lib,
  melpaBuild,
  fetchFromGitHub,
}:

melpaBuild {
  pname = "gguf";
  version = "0-unstable-2026-08-15";

  src = fetchFromGitHub {
    owner = "nagy";
    repo = "gguf.el";
    rev = "24c62552e95d0d3c6a079e507708bfc546c7348c";
    hash = "sha256-OuDtSTn56bHqma3txFou6G+XHXy5FtF+Wm8ateUObb4=";
  };

  turnCompilationWarningToError = true;

  meta = {
    homepage = "https://github.com/nagy/gguf.el";
    description = "Major mode for viewing GGUF file metadata";
    license = lib.licenses.agpl3Plus;
    maintainers = with lib.maintainers; [ nagy ];
  };
}
