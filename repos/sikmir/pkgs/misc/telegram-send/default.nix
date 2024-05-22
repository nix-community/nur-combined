{
  lib,
  fetchFromGitHub,
  fetchpatch,
  python3Packages,
}:

python3Packages.buildPythonApplication rec {
  pname = "telegram-send";
  version = "0-unstable-2023-10-07";

  src = fetchFromGitHub {
    owner = "rahiel";
    repo = "telegram-send";
    rev = "38cd39fb0eac6c58e886c11706ae39f58991af55";
    hash = "sha256-DeEz1cVor2GBoQrDIHNWr5IYnPgBsTWr5xMuSM38MBw=";
  };

  postPatch = ''
    substituteInPlace setup.py \
      --replace-fail "python-telegram-bot==20.6" "python-telegram-bot"
  '';

  nativeBuildInputs = with python3Packages; [ pip ];

  propagatedBuildInputs = with python3Packages; [
    appdirs
    colorama
    python-telegram-bot
  ];

  doCheck = false;

  meta = with lib; {
    description = "Send messages and files over Telegram from the command-line";
    homepage = "https://www.rahielkasim.com/telegram-send/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
