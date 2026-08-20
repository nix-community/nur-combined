{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "usbguard-tui";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "usbguard-tui";
    rev = "v${version}";
    hash = "sha256-npbU82IC0ExgRYjsjJXm1zyuzh+222UP/fSn6xtMdpQ=";
  };

  vendorHash = "sha256-8QP2FbNmvqrJhFe3Ia7tPhkxMeFWBhvr4Zr9kpV9bR4=";

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
