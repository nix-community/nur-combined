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
  version = "1.15.0-alpha.11";
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
    hash = "sha256-SETjm9kMoo4M+EgrSXA36sLDQvHyPXRbPXyhDDds5mM=";
  };
  vendorHash = "sha256-O18+Y7wlcSUFRo54jC4Ogb8AtnPuLG7rPhzIDCC6sjU=";
  updateExtraArgs = [
    "--version"
    "unstable"
    "--version-regex"
    "v(.*-(?:alpha|beta|rc).*)"
    "--override-filename"
    "pkgs/sing-box/beta.nix"
  ];
}
