{
  lib,
  buildGoModule,
  fetchFromGitHub,
  installShellFiles,
  coreutils,
  lld,
  nix-update-script,
  nixosTests,
  withCGO ? false,
}:
let
  version = "1.14.5";
in
import ./common.nix {
  inherit
    lib
    buildGoModule
    installShellFiles
    coreutils
    lld
    nix-update-script
    nixosTests
    version
    withCGO
    ;

  pname = "sing-box";
  homepage = "https://sing-box.sagernet.org";
  src = fetchFromGitHub {
    owner = "SagerNet";
    repo = "sing-box";
    tag = "v${version}";
    hash = "sha256-BID9YMyyqkx4itqzzBU48DFp3ndXU/J5x5kEss3GK4k=";
  };
  vendorHash = "sha256-oq5JCK4Y6p1YeRDAtPrSC/KcsaN6ioKoYk9k2W5ehNQ=";
  updateExtraArgs = [
    "--override-filename"
    "pkgs/sing-box/stable.nix"
  ];
}
