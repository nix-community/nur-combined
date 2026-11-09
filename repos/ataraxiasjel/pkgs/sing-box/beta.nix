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
  version = "1.15.0-alpha.13";
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
    hash = "sha256-N0Ov1YVNpsCdt2G9cS6jHs52gCvbZ4+CL3kFRuKfYts=";
  };
  vendorHash = "sha256-3SyWbFw727nZRCaECDl+Bu1w1yhYB+fzUxvCKw2om6w=";
  updateExtraArgs = [
    "--version"
    "unstable"
    "--version-regex"
    "v(.*-(?:alpha|beta|rc).*)"
    "--override-filename"
    "pkgs/sing-box/beta.nix"
  ];
}
