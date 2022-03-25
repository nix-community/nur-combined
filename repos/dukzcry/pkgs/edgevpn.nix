{ lib, stdenv, buildGo117Module, fetchFromGitHub }:

buildGo117Module rec {
  pname = "edgevpn";
  version = "0.11.2";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "0byy5gw089wxqx91lfq7ff6l1gm4b03s662xnq8wpz6yffpc8qbf";
  };

  vendorSha256 = "1cg5g5d3jfzfjj02xdp9pgvxf2gk5mi62hqijig6br2lj8jqhgz0";

  preBuild = ''
    substituteInPlace internal/version.go \
      --replace 'Version = ""' 'Version = "${src.rev}"'
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
