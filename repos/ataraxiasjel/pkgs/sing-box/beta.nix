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
  version = "1.15.0-alpha.10";
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
    hash = "sha256-7e+8EXtZN3x/vrgOzxu7ze+2EjTQLWnhHpDcjqLTHc0=";
  };
  vendorHash = "sha256-V3brKNtqm6wOkptf13rVb9acTQ1tj6lgnSTacTpvk/I=";
  updateExtraArgs = [
    "--version"
    "unstable"
    "--version-regex"
    "v(.*-(?:alpha|beta|rc).*)"
    "--override-filename"
    "pkgs/sing-box/beta.nix"
  ];
}
