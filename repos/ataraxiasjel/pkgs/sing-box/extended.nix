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
  version = "1.14.3-extended-2.7.3";
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
    hash = "sha256-1xopWHom+RZLhjhScUpA3UFvS4DjJVaXc2zJcTnfcTQ=";
  };
  vendorHash = "sha256-r51H+rVlK6wR+bdtQSPUNJAOCr1/Oy3wUeYPOyw2bEU=";
  updateExtraArgs = [
    "--version"
    "unstable"
    "--version-regex"
    "v(.*-extended.*)"
    "--override-filename"
    "pkgs/sing-box/extended.nix"
  ];
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
