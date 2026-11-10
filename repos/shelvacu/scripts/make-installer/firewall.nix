{ pkgs, ... }:
pkgs.writeShellApplication {
  name = "installer-pxe-firewall";
  runtimeInputs = with pkgs; [
    python3
    nftables
    iptables
  ];
  text = ''
    exec python3 ${./pxe-firewall.py} "$@"
  '';
}
