{ lib, stdenv, buildGo118Module, fetchFromGitHub }:

buildGo118Module rec {
  pname = "edgevpn";
  version = "0.19.0";

  src = fetchFromGitHub {
    owner = "mudler";
    repo = pname;
    rev = "v${version}";
    sha256 = "sha256-ylkdEtYNft7rmFx2NmCBynStJagdUYON/LHqvGznRhc=";
  };

  vendorSha256 = "sha256-CSwsjjliVNOf1YsVoeqZbEO7hEVMH4RPvhkzN5S1hME=";

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
