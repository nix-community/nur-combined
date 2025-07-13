{
  lib,
  fetchFromGitHub,
  python3Packages,
}:

python3Packages.buildPythonApplication {
  pname = "telegram-send";
  version = "0-unstable-2023-10-07";
  pyproject = true;

  src = fetchFromGitHub {
    owner = "rahiel";
    repo = "telegram-send";
    rev = "38cd39fb0eac6c58e886c11706ae39f58991af55";
    hash = "sha256-DeEz1cVor2GBoQrDIHNWr5IYnPgBsTWr5xMuSM38MBw=";
  };

  build-system = with python3Packages; [ setuptools ];

  nativeBuildInputs = with python3Packages; [ pip ];

  dependencies = with python3Packages; [
    appdirs
    colorama
    python-telegram-bot
  ];

  pythonRelaxDeps = true;

  doCheck = false;

  meta = {
    description = "Send messages and files over Telegram from the command-line";
    homepage = "https://www.rahielkasim.com/telegram-send/";
    license = lib.licenses.gpl3Plus;
    maintainers = [ lib.maintainers.sikmir ];
  };
}
