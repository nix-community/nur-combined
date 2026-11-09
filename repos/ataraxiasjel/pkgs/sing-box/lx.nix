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
  version = "1.15.0-lx.1-rc.1";
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
    hash = "sha256-3M0wkA0pJ5a2kmLy3S53EEf6Dlc5by2PvAmOwts57yw=";
    # go.mod replaces 4 modules with local fork submodules
    # (wireguard-go/sing-tun/gvisor/utls), so the source must
    # include submodules, like the fork's own CI clone does.
    fetchSubmodules = true;
  };
  vendorHash = "sha256-yAJXPN9NjDbXJecf9yBCoSKQ8CKzf+C9OKacBzizVy8=";
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
    "--version"
    "unstable"
    "--version-regex"
    "v(.*-lx\\..*)"
    "--override-filename"
    "pkgs/sing-box/lx.nix"
  ];
}
