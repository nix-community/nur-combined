{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "jwt-tui";
  version = "0.2.1";

  src = fetchFromGitHub {
    owner = "Chiloute";
    repo = "jwt-tui";
    rev = "v${version}";
    hash = "sha256-d4Hwc6/y4XacokiW9fNS2isSRmbOWE5WsOjhNqJ3Uvc=";
  };

  vendorHash = "sha256-/NtGoOQ6AWV47P3vOO/n99DGvxv4Tgv/Jj4G18aow1Y=";

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
