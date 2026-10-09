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
  version = "1.14.3";
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
    hash = "sha256-Cy95gViVKmMYSXTKDbOxCOna7nBJ2b7/b8min1hZ2mM=";
  };
  vendorHash = "sha256-wWe4aUpiCD+wgsj7YPJYVER7PxfgUbVTAhjarEzLtTc=";
  updateExtraArgs = [
    "--override-filename"
    "pkgs/sing-box/stable.nix"
  ];
}
