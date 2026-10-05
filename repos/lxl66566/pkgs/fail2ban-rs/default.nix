{
  stdenv,
  lib,
  pkgs,
  makeBinPackage,
}:

let
  pname = "fail2ban-rs";
  bname = "fail2ban-rs";
  description = "A pure-Rust fail2ban replacement. Single static binary, fast two-phase matching, nftables/iptables/ipset firewall backends.";

  sourceInfo = lib.importJSON ./source-info.json;
  commonArgs = {
    inherit
      pname
      bname
      description
      ;
  }
  // sourceInfo;

  # upstream only ships static musl builds
  musl = makeBinPackage (
    commonArgs
    // {
      nixSystem = stdenv.hostPlatform.system;
      libc = "musl";
      overrideStdenv = pkgs.pkgsStatic.stdenv;
    }
  );

  packages = lib.mapAttrs (
    nixSystem: libcMap:
    lib.mapAttrs (
      libc: _:
      makeBinPackage (
        commonArgs
        // {
          inherit nixSystem libc;
          overrideStdenv = if libc == "musl" then pkgs.pkgsStatic.stdenv else null;
        }
      )
    ) libcMap
  ) sourceInfo.hashes;

in

musl.overrideAttrs (oldAttrs: {
  passthru = {
    inherit packages;
  };
})
