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
  version = "1.15.0-alpha.12";
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
    hash = "sha256-Xu2lsqcGdKdRTEcWwIX6EFuEd87ImnWGI4Vp10aO37Y=";
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
