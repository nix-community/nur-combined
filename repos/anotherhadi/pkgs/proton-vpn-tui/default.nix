{
  lib,
  buildGo126Module,
  fetchFromGitHub,
}:
buildGo126Module rec {
  pname = "proton-vpn-tui";
  version = "0.0.1";

  src = fetchFromGitHub {
    owner = "anotherhadi";
    repo = "proton-vpn-tui";
    rev = "v${version}";
    hash = "sha256-vIxGjcBKDSO9vL+A6vsPFDM5L0X140B0qIwvh6HyiVI=";
  };

  vendorHash = "sha256-+mUN+uR0Amn0shSIVe0aQ6JDv395SyLA060cpOcGrb0=";

  ldflags = [ "-s" "-w" "-X main.version=${version}" ];

  meta = with lib; {
    description = "A minimal, TUI and keyboard friendly wrapper for proton-vpn-cli";
    homepage = "https://github.com/anotherhadi/proton-vpn-tui";
    license = licenses.mit;
    platforms = platforms.unix;
    maintainers = [ ];
    mainProgram = "proton-vpn-tui";
  };
}
