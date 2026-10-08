{ pkgs, lib }:
let
  src = pkgs.fetchzip {
    url = "https://github.com/reckenrode/nixpkgs/archive/refs/heads/swift-6.3-update.tar.gz";
    hash = "sha256-JmLCtK98no7ZbCMGq8kMjie2hUWBuI8rEBpm/pT6PTQ=";
  };
  nixpkgs-swift = import src {
    system = pkgs.system;
    config = pkgs.config;
  };
in
nixpkgs-swift.swift.overrideAttrs (old: {
  meta = (old.meta or { }) // {
    description = "Swift 6.3.3 (from reckenrode/nixpkgs PR #565702)";
  };
  passthru = (old.passthru or { }) // {
    inherit (nixpkgs-swift) swiftPackages;
  };
})
