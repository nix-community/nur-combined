{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "usbguard-tui";
  version = "1.1.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "usbguard-tui";
    rev = "v${version}";
    hash = "sha256-m4Bg2uy9WqYHaTod/dJfFUHCAXDwg6+4GLXGUIAid5Q=";
  };

  vendorHash = "sha256-tXMeJy9IpXTRhikYedcL+76H9X3In9mb1/KnN1XFPu4=";

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
