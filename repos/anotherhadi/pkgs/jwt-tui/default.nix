{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "jwt-tui";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "jwt-tui";
    rev = "v${version}";
    hash = "sha256-DqoRRKGk7rj1kP62R1gmOFAijxTaOu1k7hv1BaXlGVM=";
  };

  vendorHash = "sha256-rh/iQ5aDSDFv8wvb7bzcxcyX8Pfab+90NVzHs/xRH+I=";

  ldflags = ["-s" "-w" "-X main.version=${version}"];

  meta = with lib; {
    description = "A TUI for inspecting, editing, and signing JSON Web Tokens (JWTs).";
    homepage = "https://github.com/anotherhadi/jwt-tui";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "jwt-tui";
  };
}
