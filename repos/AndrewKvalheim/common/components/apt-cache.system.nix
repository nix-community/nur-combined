{ pkgs, ... }:

let
  inherit (pkgs) writeTextDir;
in
{
  imports = [ ../../packages/apt-cacher-ng.nix ];

  config = {
    networking.firewall.extraCommands = ''
      iptables --wait --table 'nat' --new-chain 'apt-cache-nat-pre'
      iptables --table 'nat' --append 'apt-cache-nat-pre' \
        --protocol 'tcp' --source '10.222.0.0/16' --dport '80' \
        --jump 'REDIRECT' --to-port '3142'
      iptables --wait --table 'nat' --append 'PREROUTING' --jump 'apt-cache-nat-pre'

      iptables --append nixos-fw \
        --protocol 'tcp' --source '10.222.0.0/16' --dport '3142' \
        --jump 'nixos-fw-accept'
    '';
    networking.firewall.extraStopCommands = ''
      iptables --wait --table 'nat' --delete 'PREROUTING' --jump 'apt-cache-nat-pre' 2>/dev/null || true
      iptables --wait --table 'nat' --flush 'apt-cache-nat-pre' 2>/dev/null || true
      iptables --wait --table 'nat' --delete-chain 'apt-cache-nat-pre' 2>/dev/null || true
    '';

    services.apt-cacher-ng.enable = true;

    environment.systemPackages = [
      (writeTextDir "share/apt-cache/docker.conf" ''
        # Run Docker container with:
        #   --add-host 'apt-cache.internal:host-gateway'
        #   --volume '/run/current-system/sw/share/apt-cache/docker.conf:/etc/apt/apt.conf.d/02cache:ro'

        Acquire::http::Proxy "http://apt-cache.internal";
        Acquire::https::Proxy "false";
      '')
    ];
  };
}
