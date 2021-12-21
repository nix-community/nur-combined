{ lib, stdenv, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "edgevpn";
  version = "0.5.1";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-sJk2cbQv+EfJyqgK4JZVRmFkmYP4fN4itmmSqbAOksc=";
  };

  vendorSha256 = "sha256-pPv0y5obD/79qSg08J7y+6g98QITrY0wdrQpfc+D0a4=";

  doCheck = false;

  meta = with lib; {
    description = "The immutable, decentralized, statically built VPN without any central server";
    homepage = src.meta.homepage;
    license = licenses.gpl3;
    maintainers = with maintainers; [ ];
    platforms = platforms.linux;
  };
}
