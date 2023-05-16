{ pkgs, ... }: {
  systemd.services."netns@" = {
    description = "%I network namespace";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };
  systemd.services."internetns" = {
    description = "Network namespace that gives Internet access";
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = [
        "${pkgs.iproute}/bin/ip netns add internetns"
        "${pkgs.iproute}/bin/ip netns exec internetns ${pkgs.iproute}/bin/ip link set lo up"
        "${pkgs.iproute}/bin/ip link add internetns_in type veth peer name internetns_out netns internetns"
        "${pkgs.iproute}/bin/ip netns exec internetns ${pkgs.iproute}/bin/ip addr add 192.168.70.2/24 dev internetns_out"
        "${pkgs.iproute}/bin/ip netns exec internetns ${pkgs.iproute}/bin/ip link set internetns_out up"
        "${pkgs.iproute}/bin/ip addr add 192.168.70.1/24 dev internetns_in"
        "${pkgs.iproute}/bin/ip link set internetns_in up"
        "${pkgs.iproute}/bin/ip netns exec internetns ${pkgs.iproute}/bin/ip route add default via 192.168.70.1 dev internetns_out"
        "${pkgs.iptables}/bin/iptables -A FORWARD -i enp2s0f1 -o internetns_in -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -A FORWARD -o enp2s0f1 -i internetns_in -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 192.168.70.2/24 -o enp2s0f1 -j MASQUERADE"
      ];
      ExecStop = [
        "${pkgs.iptables}/bin/iptables -D FORWARD -i enp2s0f1 -o internetns_in -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -D FORWARD -o enp2s0f1 -i internetns_in -j ACCEPT"
        "${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 192.168.70.2/24 -o enp2s0f1 -j MASQUERADE"
        "${pkgs.iproute}/bin/ip link delete internetns_in"
        "${pkgs.iproute}/bin/ip netns del internetns"
      ];
    };
  };
}
