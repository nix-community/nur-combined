{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "unbound_exporter";
  version = "0.3";

  src = fetchFromGitHub {
    owner = "kumina";
    repo = pname;
    rev = "v${version}";
    sha256 = "0v752z3k5vikikph1z19bx9s2iqf8sb32jlcas27hvz52h7d78g8";
  };

  vendorSha256 = "0zaj7gy0xbbsqm1zzqnk7pxyw80dy516fyx0j5b8wjqx34b5if2p";
  modSha256 = vendorSha256;

  buildFlagsArray = [ "-ldflags=-s -w -X main.version=${version}" ];

  meta = with lib; {
    description = "Prometheus exporter for Unbound";
    homepage = "https://github.com/kumina/unbound_exporter";
    maintainers = [ maintainers.c0deaddict ];
    license = licenses.asl20;
  };
}
