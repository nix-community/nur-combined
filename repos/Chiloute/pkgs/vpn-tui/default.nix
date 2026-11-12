# Engineering lives upstream: build recipes (nix/daemon.nix, nix/app.nix) and their
# hashes come from the tagged source. Only version + src hash are maintained here (nix-update).
{
  lib,
  callPackage,
  symlinkJoin,
  fetchFromGitHub,
}: let
  version = "0.1.0";

  src = fetchFromGitHub {
    owner = "Chiloute";
    repo = "vpn-tui";
    rev = "v${version}";
    hash = "sha256-JpNXMpAv/o2y38n0a065WXjmAd4g1AgR6XcwP34J5DU=";
  };

  vpn-tuid = callPackage "${src}/nix/daemon.nix" {inherit version;};
  client = (callPackage "${src}/nix/app.nix" {inherit version;}).package;
in
  symlinkJoin {
    pname = "vpn-tui";
    inherit version;
    paths = [vpn-tuid client];
    passthru = {inherit src vpn-tuid client;};
    meta = {
      description = "VPN manager (OpenVPN/WireGuard) with kill switch: Go daemon vpn-tuid and TUI/CLI client";
      homepage = "https://github.com/Chiloute/vpn-tui";
      license = lib.licenses.mit;
      platforms = ["x86_64-linux" "aarch64-linux"];
      mainProgram = "vpn-tui";
    };
  }
