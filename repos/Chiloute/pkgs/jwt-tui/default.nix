{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "jwt-tui";
  version = "0.2.0";

  src = fetchFromGitHub {
    owner = "Chiloute";
    repo = "jwt-tui";
    rev = "v${version}";
    hash = "sha256-l4wPrHA93Mp/D8eGyAI6nAZ/IQ/Z3yHtDURJWIsd47Y=";
  };

  vendorHash = "sha256-dgfH1uy2OK/EScmt+dsHwxO0bNObdKTDCMNN3MyPJ5k=";

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
