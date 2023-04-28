{ lib, fetchFromGitHub, fetchpatch, python3Packages }:

python3Packages.buildPythonApplication rec {
  pname = "telegram-send";
  version = "2022-05-13";

  src = fetchFromGitHub {
    owner = "rahiel";
    repo = "telegram-send";
    rev = "34d7703754d441a6f4c4a7b5b3210759d36078e2";
    hash = "sha256-/+hNnUT7kA19wpiHGNPVMQGostjoaDzHd91WYruJq0w=";
  };

  patches = [
    # Update for PTB v20
    (fetchpatch {
      url = "https://github.com/rahiel/telegram-send/commit/daf6c404ce9dfcd94cfec789aedd622942f11091.patch";
      hash = "sha256-e236VJVw/sPT583yB5kHEingT7w+3CyCslpzETcHWXo=";
    })
  ];

  propagatedBuildInputs = with python3Packages; [ appdirs colorama python-telegram-bot ];

  meta = with lib; {
    description = "Send messages and files over Telegram from the command-line";
    homepage = "https://www.rahielkasim.com/telegram-send/";
    license = licenses.gpl3Plus;
    maintainers = [ maintainers.sikmir ];
  };
}
