{
  self,
  inputs,
  ...
}:
{
  flake.modules.nixos.june =
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

      networking.firewall.extraInputRules = ''
        iifname "vm2" ip saddr 10.255.0.2 ip daddr 10.255.0.0 tcp dport { 3030, 53, 9222 } accept
      '';
      # systemd.sockets.forward-9222 = {
      #   description = "socket for port 9222 forwarding";
      #   wantedBy = [ "sockets.target" ];
      #   socketConfig = {
      #     ListenStream = "10.255.0.0:9222";
      #     # bind explicitly to the device
      #     BindToDevice = "vm2";
      #     # optional: allow binding even if the interface is not fully up yet
      #     FreeBind = true;
      #   };
      # };

      # systemd.services.forward-9222 = {
      #   description = "forward 9222 to localhost";
      #   requires = [ "forward-9222.socket" ];
      #   after = [ "forward-9222.socket" ];
      #   serviceConfig = {
      #     # execute the built-in systemd proxy
      #     ExecStart = "${pkgs.systemd}/lib/systemd/systemd-socket-proxyd 127.0.0.1:9222";

      #     # security hardening
      #     DynamicUser = true;
      #     PrivateTmp = true;
      #     NoNewPrivileges = true;
      #   };
      # };
      # networking = {
      #   nat = {
      #     enable = true;
      #     enableIPv6 = true;
      #     internalIPv6s = [ "fcbd::809c:183e:12fb:9ff0:1/64" ];
      #     # the interface with upstream Internet access, TODO: change with host
      #     externalInterface = "eno1";
      #   };
      # };
      #
      services.realm = {
        enable = true;
        settings = {
          log.level = "warn";
          network = {
            no_tcp = false;
            use_udp = true;
          };
          endpoints = [
            {
              listen = "10.255.0.0:9222";
              remote = "127.0.0.1:9222";
            }
          ];
        };
      };
      microvm.autostart = [
        "june"
      ];
      microvm.vms = {
        june =
          let
            index = 2;
            mac = "00:00:00:00:00:02";
          in
          {
            inherit pkgs;
            restartIfChanged = true;
            specialArgs = {
            };

            config = {
              imports = [
                # ../../nixosModules/hysteria.nix
                inputs.hermes-agent.nixosModules.default
                self.modules.nixos.bub
              ];
              networking.hostName = "june";
              networking.useNetworkd = true;
              system.stateVersion = "25.11";
              networking.firewall = {
                # forbid access to RFC1918 addr scope & IPv6
                enable = true;
                allowedTCPPorts = [
                ];
              };
              networking.nftables.enable = true;
              networking.enableIPv6 = true;
              # forbid end
              networking.firewall.interfaces =
                let
                  matchAll = if !config.networking.nftables.enable then "podman+" else "podman*";
                in
                {
                  "${matchAll}".allowedUDPPorts = [ 53 ];
                };

              virtualisation = {
                vmVariant = {
                  virtualisation = {
                    memorySize = 2048;
                    cores = 6;
                  };
                };

                podman = {
                  enable = true;
                  dockerSocket.enable = true;
                  dockerCompat = true;
                  defaultNetwork.settings = {
                    dns_enabled = true;
                  };
                };
                docker.enable = false;

                oci-containers.backend = "podman";
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
              users.users.agent = {
                isNormalUser = true;
                uid = 1000;
                initialHashedPassword = lib.mkDefault config.data.keys.hashedPasswd;
              };
              # services.hermes-agent = {
              #   enable = true;
              #   package = inputs.hermes-agent.packages.${pkgs.stdenv.hostPlatform.system}.full;
              #   container = {
              #     enable = true;
              #     hostUsers = [ "agent" ];
              #     backend = "podman";
              #   };
              #   addToSystemPackages = true;
              #   environmentFiles = [ "/var/lib/hermes/env" ];
              # };
              security.sudo.extraRules = [
                {
                  users = [ "agent" ];
                  commands = [
                    {
                      command = "/run/current-system/sw/bin/podman";
                      options = [ "NOPASSWD" ];
                    }
                  ];
                }
              ];
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
                "net.ipv6.conf.all.forwarding" = 1;
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
                git
                helix
              ];
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
                          host = "june",
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
                vcpu = 4;
                mem = 1536;
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
                    size = 16384;
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
                  {
                    proto = "virtiofs";
                    tag = "bub";
                    # Source path can be absolute or relative
                    # to /var/lib/microvms/$hostName
                    source = "/home/riro/Src/bub";
                    mountPoint = "/home/agent/bub";
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
