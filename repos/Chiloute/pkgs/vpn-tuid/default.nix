{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "vpn-tuid";
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Chiloute";
    repo = "vpn-tui";
    rev = "v${version}";
    hash = "sha256-JpNXMpAv/o2y38n0a065WXjmAd4g1AgR6XcwP34J5DU=";
  };

  vendorHash = "sha256-3O+215G9KuNSYjFVDpDMyXrXNX3tYxFb+2zRnSz9IUw=";

  subPackages = ["daemon/cmd/vpn-tuid"];
  env.CGO_ENABLED = 0;
  env.GOTOOLCHAIN = "local";
  ldflags = ["-s" "-w" "-X main.version=${version}"];

  meta = with lib; {
    description = "vpn-tui daemon (OpenVPN/WireGuard, kill switch)";
    homepage = "https://github.com/Chiloute/vpn-tui";
    license = licenses.mit;
    platforms = platforms.linux;
    maintainers = [];
    mainProgram = "vpn-tuid";
  };
}
