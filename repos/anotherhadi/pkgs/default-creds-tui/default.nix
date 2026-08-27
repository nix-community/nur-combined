{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "default-creds-tui";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "default-creds-tui";
    rev = "v${version}";
    hash = "sha256-oVtTaNHrUoe79pfJHdS0vPpzg/HfpS4qriNAeSGrykE=";
  };

  vendorHash = "sha256-t7jZbEbssx3hdttBjBOAqUIrSWafz4rES11g86JOrSg=";

  ldflags = ["-s" "-w" "-X main.version=${version}"];

  meta = with lib; {
    description = "Find default credentials for many devices and software, without leaving the terminal";
    homepage = "https://github.com/anotherhadi/default-creds-tui";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "default-creds-tui";
  };
}
