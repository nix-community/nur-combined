{ self, inputs, ... }:
{
  flake.modules.nixos.sept =
    {
      pkgs,
      lib,
      ...
    }:
    {
      imports = [
        inputs.microvm.nixosModules.host
        self.modules.nixos.routed-subnet
      ];

      networking.firewall.extraInputRules = ''
        iifname "vm1" ip saddr 10.255.0.1 ip daddr 10.255.0.0 tcp dport { 3030, 53 } accept
      '';
      networking = {
        nat = {
          enable = true;
          enableIPv6 = true;
          internalIPv6s = [ "fcbd::ad41:a5b0:eefb:d24c:1/64" ];
          # the interface with upstream Internet access, TODO: change with host
          externalInterface = "eno1";
        };
      };
      microvm.autostart = [
        "sept"
      ];
      microvm.vms = {
        sept =
          let
            index = 1;
            mac = "00:00:00:00:00:01";
          in
          {
            inherit pkgs;
            restartIfChanged = true;
            specialArgs = {
            };

            config = {
              imports = [
                ../../nixosModules/hysteria.nix
              ];
              networking.hostName = "sept";
              networking.useNetworkd = true;
              system.stateVersion = "25.11";
              networking.firewall = {

                # forbid access to RFC1918 addr scope & IPv6
                enable = true;
                allowedTCPPorts = [
                  1095
                  8080
                  9100
                ];
                allowedUDPPorts = [ 53 ];
              };
              networking.nftables.enable = true;
              networking.nftables.tables = {
                # nat table configuration
                nat = {
                  family = "inet";
                  content = ''
                    chain postrouting {
                      type nat hook postrouting priority srcnat; policy accept;
                      
                      # outbound nat for wireguard clients
                      iifname "wg-ext" oifname "enp0s4" ip saddr 10.10.10.0/24 masquerade
                      iifname "wg-ext" oifname "enp0s4" meta nfproto ipv6 snat to fec0::1
                    }
                  '';
                };

                # filter table configuration
                filter = {
                  family = "inet";
                  content = ''
                    chain forward {
                      type filter hook forward priority filter; policy drop;

                      # allow return traffic
                      ct state { established, related } accept

                      # drop specific internal destinations for wg-ext
                      iifname "wg-ext" ip daddr 10.255.0.0 reject with icmp admin-prohibited
                      iifname "wg-ext" ip6 daddr fec0::/128 reject with icmpv6 admin-prohibited

                      # allow wg-ext to access external network via enp0s4
                      iifname "wg-ext" oifname "enp0s4" accept

                      # vm, dont have podman
                      # iifname "podman*" accept
                      # oifname "podman*" accept
                    }
                  '';
                };
              };
              networking.enableIPv6 = true;
              # forbid end

              services.prometheus.exporters = {
                node = {
                  enable = true;
                  listenAddress = "[::]";
                  enabledCollectors = [ "systemd" ];
                  disabledCollectors = [ "arp" ];
                };
              };
              services.openssh.hostKeys = [
                {
                  path = "/var/lib/ssh/ssh_host_ed25519_key";
                  type = "ed25519";
                }
              ];
              services.resolved.settings.Resolve.DNSStubListenerExtra = "10.10.10.1";
              boot.kernel.sysctl = {
                "net.ipv4.tcp_rfc1337" = 1;
                "net.ipv4.tcp_fastopen" = 0;
                "net.ipv4.tcp_congestion_control" = "bbr";
                "net.ipv6.tcp_congestion_control" = "bbr";
                "net.core.default_qdisc" = "cake";
                "net.ipv4.tcp_rmem" = "4096 87380 2500000";
                "net.ipv4.tcp_wmem" = "4096 65536 2500000";
                "net.core.rmem_max" = 16777216;
                "net.core.wmem_max" = 16777216;
                "net.ipv4.conf.all.forwarding" = 1;
              };
              systemd.network = {

                netdevs.wg-ext = {
                  netdevConfig = {
                    Kind = "wireguard";
                    Name = "wg-ext";
                    MTUBytes = 1380;
                  };
                  wireguardConfig = {
                    PrivateKeyFile = "/var/lib/wg-ext/key";
                  };
                  wireguardPeers = [
                    {
                      PublicKey = "2pmaKNynwrVEvOcUXuFfYDGRp5UKbK89DmOSCnjklRk=";
                      Endpoint = "127.0.0.1:51700";
                      PersistentKeepalive = 15;
                      AllowedIPs = [
                        "10.10.10.2/32"
                        "fcbd::ad41:a5b0:eefb:d24c:2/128"
                      ];
                    }
                  ];
                };
                networks."90-wg-ext" = {
                  matchConfig.Name = "wg-ext";
                  address = [
                    "10.10.10.1/24"
                    "fcbd::ad41:a5b0:eefb:d24c:1/64"
                  ];
                  DHCP = "no";
                };

                networks."10-eth" = {
                  matchConfig.MACAddress = mac;
                  # Static IP configuration
                  address = [
                    "10.255.0.${toString index}/32"
                    "fec0::${lib.toHexString index}/128"
                  ];
                  routes = [
                    {
                      # Default route
                      Destination = "0.0.0.0/0";
                      Gateway = "10.255.0.0";
                      GatewayOnLink = true;
                    }
                    {
                      # Default route
                      Destination = "::/0";
                      Gateway = "fec0::";
                      GatewayOnLink = true;
                    }
                  ];
                  networkConfig = {
                    # DNS servers no longer come from DHCP nor Router
                    # Advertisements. Perhaps you want to change the defaults:
                    DNS = [
                      "10.255.0.0"
                    ];
                  };
                };
              };
              users.users.root = {
                initialHashedPassword = "$2b$05$y36LF2A5ybA9oA0LuJnZMu4BjBJvPn.CpjEbdQRDSZn8z4N7RYm9W";
                openssh.authorizedKeys.keys = [
                  "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+HwSzDbhJOIs8cMuUaCsvwqfla4GY6EuD1yGuNkX6QAAAADnNzaDoxNjg5NTQzMzc1"
                  "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDcYqby4TnhKV6xGyuZUtxOmTtXjKYp8r+uCxbGph65"
                ];
              };
              environment.systemPackages = with pkgs; [
                wireguard-tools
                tcpdump
                nmap
                mtr
                traceroute
                nftables
                htop
                q
                lsof
              ];
              services.hysteria.instances = {
                ext = {
                  enable = true;
                  configFile = "/var/lib/hy/config.yml";
                };
              };
              services.openssh = {
                enable = true;
                settings = {
                  PasswordAuthentication = false;
                  PermitRootLogin = "prohibit-password";
                  UseDns = false;
                  X11Forwarding = false;
                  KexAlgorithms = [
                    # pqc
                    "mlkem768x25519-sha256"
                    "sntrup761x25519-sha512"
                    "sntrup761x25519-sha512@openssh.com"
                  ];
                };
                authorizedKeysFiles = [ "/etc/ssh/authorized_keys.d/%u" ];
                extraConfig = ''
                  ClientAliveInterval 60
                  ClientAliveCountMax 720
                '';
              };
              services.alloy.enable = true;
              environment.etc."alloy/config.alloy".text = # alloy
                ''
                  livedebugging {
                    enabled = false
                  }
                  discovery.relabel "journal" {
                  	targets = []
                  	rule {
                  		source_labels = ["__journal__systemd_unit"]
                  		target_label  = "unit"
                  	}
                  }
                  loki.source.journal "journal" {
                      max_age       = "12h0m0s"
                      relabel_rules = discovery.relabel.journal.rules
                      forward_to    = [loki.write.default.receiver]
                      labels        = {
                          host = "sept",
                          job  = "systemd-journal",
                      }
                  }
                  loki.write "default" {
                  	endpoint {
                  		url = "http://10.255.0.0:3030/loki/api/v1/push"
                  	}
                  	external_labels = {}
                  }
                '';
              microvm = {
                interfaces = [
                  {
                    id = "vm${toString index}";
                    type = "tap";
                    inherit mac;
                  }
                ];
                volumes = [
                  {
                    mountPoint = "/var";
                    image = "var.img";
                    size = 256;
                  }
                ];
                shares = [
                  {
                    # use proto = "virtiofs" for MicroVMs that are started by systemd
                    proto = "9p";
                    tag = "ro-store";
                    # a host's /nix/store will be picked up so that no
                    # squashfs/erofs will be built for it.
                    source = "/nix/store";
                    mountPoint = "/nix/.ro-store";
                  }
                ];

                # "qemu" has 9p built-in!
                hypervisor = "qemu";
                socket = "control.socket";
              };
            };
          };
      };
    };
}
