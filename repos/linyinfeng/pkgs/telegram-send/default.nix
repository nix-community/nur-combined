{ sources, lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  inherit (sources.telegram-send) pname version src;

  patches = [
    # https://github.com/rahiel/telegram-send/pull/103
    ./fix-delete.patch
  ];

  propagatedBuildInputs = with python3Packages; [
    python-telegram-bot
    colorama
    appdirs
  ];

  meta = with lib; {
    homepage = "https://github.com/rahiel/telegram-send";
    description = "Send messages and files over Telegram from the command-line";
    license = licenses.mit;
  };
}
