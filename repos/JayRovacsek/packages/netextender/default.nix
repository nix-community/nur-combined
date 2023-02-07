{ buildFHSUserEnv, callPackage, writeScript }:
let
  # WARNING: THIS DOES NOT WORK CURRENTLY
  netextender = callPackage ./netextender.nix { };
  runScript = writeScript "netextender-init" ''
    rm -r /tmp/netextender-chroot
    mkdir -p /tmp/netextender-chroot/ppp
    cp -r ${netextender}/etc-skeleton/ppp/ /tmp/netextender-chroot/
    bash
    rm -r /tmp/netextender-chroot
  '';
  extraBuildCommands = "";
in buildFHSUserEnv {
  name = "netextenderchroot";
  multiPkgs = pkgs: with pkgs; [ netextender ppp iproute kmod wireguard-tools ];
  inherit extraBuildCommands runScript;
}
