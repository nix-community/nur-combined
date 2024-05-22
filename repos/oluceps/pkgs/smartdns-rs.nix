{
  fetchFromGitHub,
  pkgs,
  lib,
}:
let
  rustPlatform = pkgs.makeRustPlatform { inherit (pkgs.fenix.minimal) cargo rustc; };
  lock = ./lock/smartdns-rs.lock;
in

rustPlatform.buildRustPackage rec {
  pname = "smartdns-rs";
  version = "a39b98325dfd341984e3b4a33baeec6ee8c3deb6";

  src = fetchFromGitHub {
    owner = "mokeyish";
    repo = "smartdns-rs";
    rev = version;
    hash = "sha256-t4ajvKSmB0ESWusEm25jSPYS7RycXeH7EfwEIj3Ypuw=";
  };

  cargoLock = {
    lockFile = lock;
    outputHashes = {
      "async-socks5-0.6.0" = "sha256-jbVwQW43vRMFsejwS6F9fcpAWTcKiTYFWM0/0o7s6/g=";
      "hickory-proto-0.24.0" = "sha256-ww66K3BPLKnwBydT6QG7KYsWm/wwI3SJw3kshMGZflw=";
      "hostname-0.3.1" = "sha256-LwQSgLIq/xqlmaSqWyoNkjzwOZH0de5tvLdZ3riokmU=";
    };
  };

  postPatch = ''
    ln -s ${lock} Cargo.lock
  '';

  doCheck = false;

  meta = with lib; {
    description = "A cross platform local DNS server (Dnsmasq like) written in rust to obtain the fastest website IP for the best Internet experience, supports DoT, DoQ, DoH, DoH3";
    homepage = "https://github.com/mokeyish/smartdns-rs";
    license = licenses.gpl3Only;
    maintainers = with maintainers; [ oluceps ];
    mainProgram = "smartdns";
  };
}
