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
  version = "1.15.0-alpha.8";
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
    hash = "sha256-g456S8Pw9GYm0E48fNUAg840r+MinxKTpbcIzQKhniA=";
  };
  vendorHash = "sha256-1xP8RLU0/ZP6j8DbNiPaI0Pnw6PpBNp2hsTTE4U+PWQ=";
  updateExtraArgs = [
    "--version"
    "unstable"
    "--version-regex"
    "v(.*-(?:alpha|beta|rc).*)"
    "--override-filename"
    "pkgs/sing-box/beta.nix"
  ];
}
