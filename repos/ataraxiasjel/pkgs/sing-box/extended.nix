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
  version = "1.14.1-extended-2.7.2";
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

  pname = "sing-box-extended";
  homepage = "https://github.com/shtorm-7/sing-box-extended";
  src = fetchFromGitHub {
    owner = "shtorm-7";
    repo = "sing-box-extended";
    tag = "v${version}";
    hash = "sha256-bDE90wcoTLBm3lDICO+z7Kl+hhIXBYZN5lsrLXQbL10=";
  };
  vendorHash = "sha256-fR6ZlkSBiM0EiGwd6mWQ07p+gMnYuhugai4x4SsUNiU=";
  extraTags = [
    # extended-specific, all non-CGO
    "with_masque"
    "with_mtproxy"
    "with_trusttunnel"
    "with_call"
    "with_sudoku"
    "with_manager"
    # with_admin_panel needs service/admin_panel/dist generated via
    # `make build_admin_panel` (npm + cmd/internal/admin_panel_pack),
    # not checked into git. Wire up later with a frontend build.
    # "with_admin_panel"
    "with_profiler"
  ];
}
