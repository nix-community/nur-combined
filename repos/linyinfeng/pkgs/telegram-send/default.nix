{ sources, lib, python3Packages }:

python3Packages.buildPythonApplication rec {
  inherit (sources.telegram-send) pname version src;

  propagatedBuildInputs = with python3Packages; [
    python-telegram-bot
    colorama
    appdirs
  ];

  meta = with lib; {
    homepage = "https://github.com/rahiel/telegram-send";
    description = "Send messages and files over Telegram from the command-line";
    license = licenses.mit;
    # https://github.com/pyca/pyopenssl/issues/873
    broken = python3Packages.pyopenssl.meta.broken;
  };
}
