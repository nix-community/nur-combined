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
  version = "1.14.2-lx.3";
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

  pname = "sing-box-lx";
  homepage = "https://github.com/Leadaxe/sing-box-lx";
  description = "Universal proxy platform with XHTTP, AmneziaWG, MASQUE and observability extras";
  src = fetchFromGitHub {
    owner = "Leadaxe";
    repo = "sing-box-lx";
    tag = "v${version}";
    hash = "sha256-qZo6pJ/lzKr2wIxQW9zkcWJDfkhRsoUojaVkLeffSzw=";
    # go.mod replaces 4 modules with local fork submodules
    # (wireguard-go/sing-tun/gvisor/utls), so the source must
    # include submodules, like the fork's own CI clone does.
    fetchSubmodules = true;
  };
  vendorHash = "sha256-FUnUSHHgykw4GLoPEmevtdaowziMJEXXdvvXEkLN810=";
  # canonical desktop tag set from Makefile.lx (LX_TAGS).
  baseTags = [
    "with_gvisor"
    "with_quic"
    "with_dhcp"
    "with_wireguard"
    "with_utls"
    "with_clash_api"
    "with_xhttp"
    "with_awg"
    "with_lx_command"
    "with_lxd"
    "with_openvpn"
    "with_openconnect"
    "with_lx_chain"
    "with_tailscale"
  ];
  # tags carry full upstream history, only consider -lx releases
  updateExtraArgs = [
    "--version-regex"
    "v(.*-lx\\..*)"
  ];
}
