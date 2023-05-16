{ pkgs, ... }: {
  systemd.services."open-port-tcp@" = {
    description = "Opens TCP port in the firewall";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iptables}/bin/iptables iptables -A INPUT -p tcp -m tcp --dport %I -j ACCEPT";
      ExecStop = "${pkgs.iptables}/bin/iptables iptables -D INPUT -p tcp -m tcp --dport %I -j ACCEPT";
    };
  };
  systemd.services."open-port-udp@" = {
    description = "Opens UDP port in the firewall";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iptables}/bin/iptables iptables -A INPUT -p udp -m tcp --dport %I -j ACCEPT";
      ExecStop = "${pkgs.iptables}/bin/iptables iptables -D INPUT -p udp -m tcp --dport %I -j ACCEPT";
    };
  };
}
