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
  version = "1.14.4";
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
    hash = "sha256-1tP0gXUTLGVR32c11nypsZSx2FtBOmKMTJkt+7j/fJU=";
  };
  vendorHash = "sha256-xZWWzvyTrbaxqHG1UdKOVLOd5dPf9z6JfPJf3WeTm5Y=";
  updateExtraArgs = [
    "--override-filename"
    "pkgs/sing-box/stable.nix"
  ];
}
