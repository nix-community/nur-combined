{ lib, stdenv, buildGo118Module, fetchFromGitHub, fetchpatch }:

let
  gomod = ./go.mod;
  gosum = ./go.sum;
in buildGo118Module rec {
  pname = "edgevpn";
  version = "0.18.1";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-FNKCphB8pxmJJUyrGHIap4tHQXZ9VcbwG6ORHiiQbK5=";
  };

  vendorSha256 = "sha256-39mZOkRYQpcBOMBRf2s/f2r9g5jGgTMhVPkoM30s2zc=";

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
