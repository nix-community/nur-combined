{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "jwt-tui";
  version = "0.2.3";

  src = fetchFromGitHub {
    owner = "Chiloute";
    repo = "jwt-tui";
    rev = "v${version}";
    hash = "sha256-JWxTchoJDWLImjPr4B3jg32IAw2hRv146K7MpD/MgyU=";
  };

  vendorHash = "sha256-xe8OBTV6JQNdlMAQUog4vPiLDUZreAa6kQCimUkaCas=";

  ldflags = ["-s" "-w" "-X main.version=${version}"];

  meta = with lib; {
    description = "A TUI to decode, tamper with, and re-sign JSON Web Tokens (HMAC, RSA, ECDSA, Ed25519).";
    homepage = "https://github.com/Chiloute/jwt-tui";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [];
    mainProgram = "jwt-tui";
  };
}
