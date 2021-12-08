{ lib, stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "edgevpn";
  version = "0.4.2";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-3nfvvXEIBmsFN0+eX1MeA7TsRgCfIquPK9PSdB+99hM=";
  };

  vendorSha256 = "sha256-fAJk4H9DNWp7aHvZ4i4UwHm1rMEzTge78wkrKWAFj2w=";

  doCheck = false;

  meta = with lib; {
    description = "The immutable, decentralized, statically built VPN without any central server";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
