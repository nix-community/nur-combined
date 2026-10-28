{ ... }:
let
  # Ports inside the container (adjacent pair).
  sshPort = 2222;
  sparePort = 2223;

  # Ports on the host, published directly by rootless Podman.
  hostSshPort = 22022;
  hostSparePort = 22023;
  udpPort = 24642;
in
{
  flake.modules.nixos.shellbox =
    {
      lib,
      pkgs,
      ...
    }:
    let
      # Tools use a read-only Nix store mount inside the persistent rootfs.
      tools = pkgs.buildEnv {
        name = "shellbox-tools";
        paths = with pkgs; [
          # shell UX
          bashInteractive
          bash-completion
          coreutils
          findutils
          gnugrep
          gnused
          gawk
          diffutils
          file
          less
          tree
          which
          procps
          psmisc
          htop
          tmux
          vim
          nano
          strace
          lsof
          # archives / transfer
          curl
          wget
          rsync
          git
          unzip
          xz
          zstd
          gzip
          # data
          jq
          yq-go
          ripgrep
          fd
          fzf
          bat
          # networking toolbox
          openssh
          socat
          netcat-openbsd
          nmap
          tcpdump
          ngrep
          mtr
          traceroute
          iputils
          inetutils
          iproute2
          nettools
          ethtool
          iperf3
          dnsutils
          whois
          conntrack-tools
          nftables
          iptables
          openssl
        ];
        pathsToLink = [
          "/bin"
          "/sbin"
        ];
        ignoreCollisions = true;
      };

      # ---------------------------------------------------------------- files
      # writeTextDir takes a path INSIDE its output dir, and the result is
      # bind-mounted at /etc/ssh/authorized_keys.d, so the name here must be
      # just the file name.
      authorizedKeys = pkgs.writeTextDir "root" ''
        sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+HwSzDbhJOIs8cMuUaCsvwqfla4GY6EuD1yGuNkX6QAAAADnNzaDoxNjg5NTQzMzc1
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDcYqby4TnhKV6xGyuZUtxOmTtXjKYp8r+uCxbGph65
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMlk4fFt1HfVenQFTyGgxHfxqPB8spVtZqzBC5R2gYNg ed-login-250928
        sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMhKqC4VMo5VOTKvdYA2vTqhNOTkyCqxifhcuAvbXJSNAAAAE3NzaDoxNzg0NzgzODMzLWdpZnQ= ssh:1784783833-gift
      '';

      sshdConfig = pkgs.writeText "shellbox-sshd_config" ''
        Port ${toString sshPort}
        AddressFamily any
        ListenAddress 0.0.0.0
        ListenAddress ::

        HostKey /etc/ssh/hostkeys/ssh_host_ed25519_key
        HostKey /etc/ssh/hostkeys/ssh_host_rsa_key

        # key-only auth, no PAM, no passwd/shadow lookups beyond getpwnam
        PermitRootLogin prohibit-password
        PasswordAuthentication no
        KbdInteractiveAuthentication no
        ChallengeResponseAuthentication no
        PubkeyAuthentication yes
        UsePAM no
        AuthorizedKeysFile /etc/ssh/authorized_keys.d/%u
        AllowUsers root
        # tools are not in the alpine PATH, put them in every session
        SetEnv PATH=${tools}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

        StrictModes no
        UseDNS no
        PrintMotd no
        PrintLastLog no
        X11Forwarding no
        AllowTcpForwarding yes
        GatewayPorts no
        ClientAliveInterval 60
        ClientAliveCountMax 720

        Subsystem sftp internal-sftp
      '';

      passwd = pkgs.writeText "shellbox-passwd" ''
        root:x:0:0:root:/root:${pkgs.bashInteractive}/bin/bash
        sshd:x:74:74:sshd:/var/empty:${pkgs.bashInteractive}/bin/bash
        nobody:x:65534:65534:nobody:/var/empty:/sbin/nologin
      '';

      group = pkgs.writeText "shellbox-group" ''
        root:x:0:
        sshd:x:74:
        nobody:x:65534:
      '';

      entrypoint = pkgs.writeTextFile {
        name = "shellbox-init";
        executable = true;
        text = ''
          #!${pkgs.bashInteractive}/bin/bash
          set -euo pipefail
          export PATH=${tools}/bin

          # Keep Python in the writable Alpine rootfs, including venv support.
          if [ ! -x /usr/bin/python3.14 ]; then
            PATH=/usr/sbin:/usr/bin:/sbin:/bin /sbin/apk add --no-cache 'python3~3.14'
          fi

          mkdir -p /run/sshd /var/empty /etc/ssh/hostkeys
          chmod 0755 /run/sshd /var/empty
          chown 0:0 /var/empty

          # Host keys live in a podman volume, generate them on first boot.
          for t in ed25519 rsa; do
            key=/etc/ssh/hostkeys/ssh_host_''${t}_key
            if [ ! -s "$key" ]; then
              ssh-keygen -q -t "$t" -N "" -C "shellbox" -f "$key"
            fi
          done

          # Run the optional startup script from the persistent home directory.
          if [ -f /root/rc.local ]; then
            if (
              export HOME=/root
              export PATH=${tools}/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
              cd /root
              ${pkgs.bashInteractive}/bin/bash /root/rc.local
            ); then
              echo "shellbox: /root/rc.local completed" >&2
            else
              rc=$?
              echo "shellbox: /root/rc.local exited with status $rc" >&2
            fi
          fi

          exec ${pkgs.openssh}/bin/sshd -D -e -f /etc/ssh/shellbox_sshd_config
        '';
      };

      healthcheck = pkgs.writeTextFile {
        name = "shellbox-healthcheck";
        executable = true;
        text = ''
          #!${pkgs.bashInteractive}/bin/bash
          exec 3<>/dev/tcp/127.0.0.1/${toString sshPort}
        '';
      };
    in
    {
      users = {
        groups.shellbox = { };
        users.shellbox = {
          isSystemUser = true;
          group = "shellbox";
          home = "/var/lib/shellbox";
          linger = true;
          createHome = true;
          uid = 986;
          autoSubUidGidRange = true;
        };
      };

      # ----------------------------------------------------------------- rootless container
      virtualisation.oci-containers = {
        backend = "podman";
        containers.shellbox = {
          # Alpine 3.24 rootfs, upgraded in place with apk to preserve data.
          # --rootfs keeps all filesystem changes across container replacement.
          image = "/var/lib/shellbox/rootfs";
          pull = "never";
          hostname = "shellbox";
          entrypoint = "/init";
          podman = {
            user = "shellbox";
            sdnotify = "healthy";
          };
          # Omit the host IP to publish on both IPv4 and IPv6.
          ports = [
            "${toString hostSshPort}:${toString sshPort}"
            "${toString hostSparePort}:${toString sparePort}"
            "${toString udpPort}:${toString udpPort}/udp"
            "22024:443/tcp"
          ];
          volumes = [
            "/var/lib/shellbox/root:/root:rw"
            "/nix/store:/nix/store:ro"
            "${entrypoint}:/init:ro"
            "${sshdConfig}:/etc/ssh/shellbox_sshd_config:ro"
            "${authorizedKeys}:/etc/ssh/authorized_keys.d:ro"
            "${passwd}:/etc/passwd:ro"
            "${group}:/etc/group:ro"
            # ssh host keys survive container replacement
            "shellbox-ssh-hostkeys:/etc/ssh/hostkeys:rw"
          ];
          extraOptions = [
            "--rootfs"
            "--sysctl=net.ipv4.ip_unprivileged_port_start=0"
            "--cap-add=NET_RAW"
            "--cap-add=NET_ADMIN"
            "--health-cmd=${healthcheck}"
            "--health-interval=30s"
            "--health-timeout=5s"
            "--health-start-period=10s"
            "--health-retries=3"
          ];
        };
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/shellbox/root 0700 shellbox shellbox -"
      ];

      # A container that comes up before its user manager exists (first
      # activation) should keep retrying instead of hitting the start limit.
      systemd.services.podman-shellbox = {
        preStart = lib.mkBefore ''
          test -d /var/lib/shellbox/rootfs/etc
          test -d /var/lib/shellbox/root
        '';
        startLimitIntervalSec = 0;
        serviceConfig = {
          # Restart even when PID 1 exits cleanly after receiving SIGTERM.
          Restart = lib.mkForce "always";
          RestartSec = "5s";
        };
      };

      networking.firewall.allowedUDPPorts = [ udpPort ];
      networking.firewall.allowedTCPPorts = [
        hostSshPort
        hostSparePort
      ];
    };
}
