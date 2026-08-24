{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "usbguard-tui";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "usbguard-tui";
    rev = "v${version}";
    hash = "sha256-Z72ZQ1jYFK9itc93fBVQUQJbx2Iw4K1l1k3GCbUO8AU=";
  };

  vendorHash = "sha256-O9DG0pxRKt8VwpZdyvoQ4wsfEbsh5npmwocmtcm2IfA=";

  ldflags = ["-s" "-w" "-X main.version=${version}"];

  meta = with lib; {
    description = "A terminal UI for managing USB devices via usbguard.";
    homepage = "https://github.com/anotherhadi/usbguard-tui";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [];
    mainProgram = "usbguard-tui";
  };
}
