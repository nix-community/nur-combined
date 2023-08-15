{
  lib,
  stdenvNoCC,
  fetchFromGitHub,
}:
stdenvNoCC.mkDerivation rec {
  pname = "pass-extension-tail";
  version = "unstable-2022-04-06";

  src = fetchFromGitHub {
    owner = "palortoff";
    repo = pname;
    rev = "e8455bc0ada9b25722d2826063b1dfdc521d5b24";
    hash = "sha256-62jTEbNuNZr6g6zvqUdfeseGNnn8Z1s3cY7i5U+a4PU=";
  };

  installFlags = [
    "PREFIX=$(out)"
    "BASHCOMPDIR=$(out)/share/bash-completion/completions"
  ];

  meta = with lib; {
    description = "A pass extension to avoid printing the password to the console";
    homepage = "https://github.com/palortoff/pass-extension-tail";
    license = licenses.gpl3;
    platforms = platforms.unix;
  };
}
