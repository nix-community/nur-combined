{ lib, stdenv, buildGo118Module, fetchFromGitHub, fetchpatch }:

let
  gomod = ./go.mod;
  gosum = ./go.sum;
in buildGo118Module rec {
  pname = "edgevpn";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-IZ3G3stirMqVpgROnlwKizDL9AOk/tRl6HUtx+xJbRk=";
  };

  vendorSha256 = "sha256-vSniAU6z9tbmuj4dw/QEv5VM1yYAtLZxi2hgctwkFOE=";

  preBuild = ''
    substituteInPlace internal/version.go \
      --replace 'Version = ""' 'Version = "${src.rev}"'
    cp ${gomod} go.mod
    cp ${gosum} go.sum
  '';

  doCheck = false;

  meta = with lib; {
    description = "The immutable, decentralized, statically built VPN without any central server";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
