{ self, inputs, ... }:
{
  flake.modules.nixos.sept =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      imports = [
        inputs.microvm.nixosModules.host
        self.modules.nixos.routed-subnet
      ];

      realm.observability.endpoints = {
        sept-node = {
          address = "10.255.0.1";
          port = 9100;
        };
        sept-wg = {
          address = "10.255.0.1";
          port = 9586;
        };
        sept-blackbox = {
          address = "10.255.0.1";
          port = 9115;
          path = "/probe";
          kind = "probe";
          probes = [
            {
              module = "icmp";
              target = "10.10.10.2";
            }
          ];
        };
      };

      systemd.sockets.fec0-ssh = {
        description = "Socket for fec0 SSH forwarding";
        wantedBy = [ "sockets.target" ];

        listenStreams = [ "[fdcc::3]:2223" ];

        socketConfig = {
          Accept = false;
          BindIPv6Only = "ipv6-only";
          FreeBind = true;
        };
      };

      systemd.services.fec0-ssh = {
        description = "Forward to fec0::1 SSH";

        serviceConfig = {
          Type = "notify";
          # Use the IPv4 backend address here.
          # sing-box transparent proxying on eihort intercepts direct TCP to [fec0::1]:22,
          # and systemd-socket-proxyd does not accept the bracketed IPv6 form as a host.
          ExecStart = "${config.systemd.package}/lib/systemd/systemd-socket-proxyd 10.255.0.1:22";

          DynamicUser = true;
          NoNewPrivileges = true;
          ProtectSystem = "strict";
          ProtectHome = true;
        };
      };

      networking.firewall.extraInputRules = ''
        iifname "vm1" ip saddr 10.255.0.1 ip daddr 10.255.0.0 tcp dport { 3030, 53 } accept
        iifname "vm1" ip saddr 10.255.0.1 ip daddr 10.255.0.0 udp dport 53 accept
      '';
      networking.firewall.extraForwardRules = ''
        iifname "vm1" oifname "eno1" ip6 saddr fec0::1 counter accept
      '';
      networking.nftables.tables.sept-ipv6-guard = {
        family = "inet";
        content = ''
          # Reject blocked destinations before established connections are accepted.
          chain input {
            type filter hook input priority -10; policy accept;
            iifname "vm1" ip6 daddr { fdcc::/16, 200::/7 } counter reject with icmpv6 admin-prohibited
          }
          chain forward {
            type filter hook forward priority -10; policy accept;
            iifname "vm1" ip6 daddr { fdcc::/16, 200::/7 } counter reject with icmpv6 admin-prohibited
          }
        '';
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

            config =
              { config, ... }:
              {
                imports = [
                  # ../../nixosModules/hysteria.nix
                  inputs.flyline.nixosModules.default
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
                    (config.services.prometheus.exporters.node.port)
                    (config.services.prometheus.exporters.blackbox.port)
                  ];
                  allowedUDPPorts = [ 53 ];
                };
                networking.nftables.enable = true;
                networking.nftables.tables = {
                  # filter table configuration
                  filter = {
                    family = "inet";
                    content = ''
                      chain forward {
                        type filter hook forward priority filter; policy drop;

                        # allow return traffic
                        ct state { established, related } accept
                      }
                    '';
                  };
                };
                networking.enableIPv6 = true;
                programs = {
                  fish.enable = true;
                  flyline.enable = true;
                };
                services.prometheus.exporters = {
                  # forbid end

                  node = {
                    enable = true;
                    listenAddress = "[::]";
                    enabledCollectors = [ "systemd" ];
                    disabledCollectors = [ "arp" ];
                  };

                  blackbox = {
                    enable = true;
                    listenAddress = "10.255.0.1";
                    configFile = (pkgs.formats.yaml { }).generate "config.yml" {
                      modules = {
                        icmp = {
                          prober = "icmp";
                        };
                      };
                    };
                  };
                };
                services.openssh.hostKeys = [
                  {
                    path = "/var/lib/ssh/ssh_host_ed25519_key";
                    type = "ed25519";
                  }
                ];
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
                        "223.5.5.5"
                      ];
                    };
                  };
                };
                users.users.root = {
                  initialHashedPassword = "$2b$05$y36LF2A5ybA9oA0LuJnZMu4BjBJvPn.CpjEbdQRDSZn8z4N7RYm9W";
                  openssh.authorizedKeys.keys = [
                    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+HwSzDbhJOIs8cMuUaCsvwqfla4GY6EuD1yGuNkX6QAAAADnNzaDoxNjg5NTQzMzc1"
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDcYqby4TnhKV6xGyuZUtxOmTtXjKYp8r+uCxbGph65"
                    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMlk4fFt1HfVenQFTyGgxHfxqPB8spVtZqzBC5R2gYNg ed-login-250928"
                    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMhKqC4VMo5VOTKvdYA2vTqhNOTkyCqxifhcuAvbXJSNAAAAE3NzaDoxNzg0NzgzODMzLWdpZnQ= ssh:1784783833-gift"
                  ];
                };
                environment.systemPackages = with pkgs; [
                  tcpdump
                  helix
                  vim
                  nmap
                  mtr
                  traceroute
                  nftables
                  htop
                  q
                  lsof
                  mimic-bpf
                ];
                # services.hysteria.instances = {
                #   ext = {
                #     enable = false;
                #     package = pkgs.hysteria;
                #     configFile = "/var/lib/hy/config.yml";
                #   };
                # };
                # services.xray = {
                #   enable = true;
                #   settingsFile = "/var/lib/xray/config.json";
                # };
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

                networking.firewall = {
                  trustedInterfaces = [
                    "podman*"
                  ];
                };
                virtualisation = {
                  # vmVariant = {
                  #   virtualisation = {
                  #     memorySize = 2048;
                  #     cores = 6;
                  #   };
                  # };

                  podman = {
                    enable = true;
                    dockerSocket.enable = true;
                    dockerCompat = true;
                    defaultNetwork.settings = {
                      dns_enabled = true;
                    };
                  };

                  oci-containers.backend = "podman";
                };
                systemd.services.socks5-kit-node4 = {
                  description = "socks5-kit node4 container";
                  wantedBy = [ "multi-user.target" ];
                  after = [
                    "podman.service"
                    "network-online.target"
                  ];
                  requires = [ "podman.service" ];
                  wants = [ "network-online.target" ];
                  path = [ pkgs.podman ];
                  serviceConfig = {
                    Type = "oneshot";
                    RemainAfterExit = true;
                    WorkingDirectory = "/var/lib/ext-xray/";
                    ExecStartPre = "${pkgs.bash}/bin/bash -c 'podman image exists localhost/socks5-kit-node4:26.9.9 || podman load -i /var/lib/ext-xray/socks5-kit-node4-amd64.tar.gz'";
                    ExecStart = "${pkgs.bash}/bin/bash /var/lib/ext-xray/run.sh";
                    ExecStop = "${pkgs.podman}/bin/podman rm -f socks5-kit-node4";
                  };
                };
                systemd.tmpfiles.rules =
                  let
                    rootPodmanConf = pkgs.writeText "root-containers.conf" ''
                      [network]
                      network_config_dir = "/var/lib/containers/storage/networks"
                    '';
                  in
                  [
                    "d /var/lib/containers/storage/networks 0700 root root - -"

                    "d /root/.config/containers 0700 root root - -"
                    "L+ /root/.config/containers/containers.conf - - - - ${rootPodmanConf}"
                  ];
                microvm = {
                  mem = 2048;
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
