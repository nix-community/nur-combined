{
  lib,
  buildGoModule,
  fetchFromGitHub,
}:

buildGoModule rec {
  pname = "gomerge";
  version = "3.4.0";

  src = fetchFromGitHub {
    owner = "Cian911";
    repo = "gomerge";
    rev = version;
    hash = "sha256-P+v7nvMWly6kB6QtBZr3RfbkOPQ5ZjPl7bBiUNjYCjM=";
  };

  vendorHash = "sha256-ToUz4vRWLKttvhEnAD6B/H+1tA4lJeEgga/SSXAc2lo=";
  subPackages = [ "cmd/gomerge" ];

  ldflags = [
    "-s"
    "-w"
    "-X main.Version=${version}"
  ];

  meta = {
    description = "Bulk merge, approve, and close GitHub pull requests from the terminal";
    homepage = "https://github.com/Cian911/gomerge";
    license = lib.licenses.mit;
    mainProgram = "gomerge";
    platforms = lib.platforms.unix;
  };
}
