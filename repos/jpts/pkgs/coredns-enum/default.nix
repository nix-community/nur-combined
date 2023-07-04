{
  lib,
  stdenv,
  buildGoModule,
  fetchFromGitHub,
}:
buildGoModule rec {
  pname = "coredns-enum";
  version = "0.2.1";
  owner = "jpts";
  repo = pname;

  src = fetchFromGitHub {
    inherit owner repo;
    rev = "v${version}";
    sha256 = "sha256-5VwyygVAGxVIE1TkkH3XpcTnk0o4eMDgnl9t143sA/k=";
  };
  vendorSha256 = "sha256-kdBbMbTvBWJl9AR0xm4VnDCItHFM/KLzQEe2qBNOAEs=";

  ldflags = [
    "-s"
    "-w"
  ];

  meta = with lib; {
    homepage = "https://github.com/${owner}/${repo}";
    changelog = "https://github.com/${owner}/${repo}/tag/v${version}";
    description = "Discover Services & Pods through DNS Records in CoreDNS";
    longDescription = ''
      A tool to enumerate Kubernetes network information through DNS alone. It attempts to list service IPs, ports, and service endpoint IPs where possible.

      The tool has two modes: wildcard & bruteforce. It will automagically detect if the DNS server you are targeting supports CoreDNS wildcards (< v1.9.0) and fallback to the bruteforce method if not. The bruteforce mode also tries to guess sensible CIDR ranges to scan by default (through parsing the API server HTTPS certificate). You can override this.
    '';
    license = licenses.mit;
    maintainers = with maintainers; [];
    platforms = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
  };
}
