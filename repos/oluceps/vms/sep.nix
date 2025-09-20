{
  inputs,
  pkgs,
  inputs',
  lib,
  ...
}:
{
  imports = [
    inputs.microvm.nixosModules.host
  ];
  microvm.autostart = [
    "sep-microvm"
  ];
  microvm.vms = {
    sep-microvm =
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
            ../modules/hysteria.nix
          ];
          networking.hostName = "sep-microvm";
          networking.useNetworkd = true;
          system.stateVersion = "25.11";

          # forbid access to RFC1918 addr scope & IPv6
          networking.firewall.enable = true;
          networking.firewall.allowedTCPPorts = [ 1095 ];
          networking.nftables.enable = true;
          networking.nftables.ruleset = ''
            table inet nat {
              chain postrouting {
                type nat hook postrouting priority srcnat; policy accept;
                iifname { wg-ext } oifname enp0s4 ip saddr 10.10.10.2 snat to 10.255.0.1
              }
            }
            table inet filter {
              chain forward {
                type filter hook forward priority filter; policy drop;

                ct state established,related accept

                iifname "wg-ext" ip daddr 10.255.0.0 reject with icmp admin-prohibited

                iifname "wg-ext" oifname "enp0s4" accept
              }
            }
          '';
          networking.enableIPv6 = false;
          # forbid end

          services.openssh.hostKeys = [
            {
              path = "/var/lib/ssh/ssh_host_ed25519_key";
              type = "ed25519";
            }
          ];
          boot.kernel.sysctl = {
            "net.ipv4.conf.default.rp_filter" = 0;
            "net.ipv6.conf.all.forwarding" = 1;
            "net.ipv6.conf.all.accept_redirects" = 0;
            "net.ipv4.conf.all.forwarding" = 1;
            "net.ipv4.conf.all.rp_filter" = 0;

            # Protect against tcp time-wait assassination hazards
            "net.ipv4.tcp_rfc1337" = 1;
            # TCP Fast Open (TFO)
            "net.ipv4.tcp_fastopen" = 0;
            # Bufferbloat mitigations
            # Requires >= 4.9 & kernel module
            "net.ipv4.tcp_congestion_control" = "bbr";
            # Requires >= 4.19
            "net.core.default_qdisc" = "cake";

            "net.ipv4.tcp_rmem" = "4096 87380 2500000";
            "net.ipv4.tcp_wmem" = "4096 65536 2500000";
            "net.core.rmem_max" = 16777216;
            "net.core.wmem_max" = 16777216;
            "net.ipv4.conf.all.send_redirects" = 0;

            "net.ipv4.tcp_tw_recycle" = 0;
            "net.ipv4.tcp_tw_reuse" = 1;
            "net.ipv4.tcp_no_metrics_save" = 1;

            # hardend
            "net.ipv4.tcp_sack" = 1;
            "net.ipv4.tcp_dsack" = 0;
            "net.ipv4.tcp_fack" = 0;

            "kernel.yama.ptrace_scope" = 2;
            "vm.mmap_rnd_bits" = 32;
            "vm.mmap_rnd_compat_bits" = 16;

            "fs.protected_symlinks" = 1;
            "fs.protected_hardlinks" = 1;

            "fs.protected_fifos" = 2;
            "fs.protected_regular" = 2;

            "net.ipv4.tcp_slow_start_after_idle" = 0;
            "vm.max_map_count" = 2147483642;
            "net.ipv4.tcp_ecn" = 1;
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
                  ];
                }
              ];
            };
            networks."90-wg-ext" = {
              matchConfig.Name = "wg-ext";
              address = [ "10.10.10.1/24" ];
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
                  # route to the host
                  Destination = "10.255.0.0/32";
                  GatewayOnLink = true;
                }
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
                  "223.6.6.6"
                  "8.8.8.8"
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
          # attack test
          environment.systemPackages = [
            pkgs.wireguard-tools
            pkgs.tcpdump
            pkgs.nmap
            pkgs.metasploit
            pkgs.mtr
            pkgs.traceroute
            pkgs.nftables

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
}
