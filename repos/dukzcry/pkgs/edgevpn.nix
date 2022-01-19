{ lib, stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "edgevpn";
  version = "0.7.1";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "017s9ks6wrahmpab0rs8nfdmfzv5k6pg75lggakxsvppra75s36r";
  };

  vendorSha256 = "1pj1d65ga8i3kn46a73f2hqqnwxdx5xxz2bpf9r6dy5h1z4gwwrn";

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
