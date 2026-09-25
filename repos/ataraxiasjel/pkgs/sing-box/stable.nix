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
  version = "1.14.2";
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
    hash = "sha256-KoJj5nn0d7uxs5x4arG1p3KGkDmaFAJKiVJ5M5vYxcU=";
  };
  vendorHash = "sha256-DJNYQeCgAouLvpA8caZ0ILi9RYV82wteV6tR3gj+sfI=";
}
