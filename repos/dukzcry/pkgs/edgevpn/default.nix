{ lib, stdenv, buildGo118Module, fetchFromGitHub, fetchpatch }:

let
  gomod = ./go.mod;
  gosum = ./go.sum;
in buildGo118Module rec {
  pname = "edgevpn";
  version = "0.16.3";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-F3eU6ueKwC/JNsTPfRHyLJ9HZAolbPq5n8tbO5+Q8lU=";
  };

  vendorSha256 = "sha256-k4paDIBVO9Utz3KBdmtxUNfa3ihjLbUho3ag83K4hmE=";

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
