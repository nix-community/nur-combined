{ ... }:
let
  adonboxUid = 977;
  sshPort = 2222;
  httpInboundPort = 2223;
  hostSshPort = 22033;
  httpinboundport = 22034;
in
{
  flake.modules.nixos.adonbox =
    {
      config,
      lib,
      pkgs,
      ...
    }:
    let
      authorizedKeys = pkgs.writeText "adonbox-authorized-keys" ''
        sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIH+HwSzDbhJOIs8cMuUaCsvwqfla4GY6EuD1yGuNkX6QAAAADnNzaDoxNjg5NTQzMzc1
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMDcYqby4TnhKV6xGyuZUtxOmTtXjKYp8r+uCxbGph65
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMlk4fFt1HfVenQFTyGgxHfxqPB8spVtZqzBC5R2gYNg ed-login-250928
        sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIMhKqC4VMo5VOTKvdYA2vTqhNOTkyCqxifhcuAvbXJSNAAAAE3NzaDoxNzg0NzgzODMzLWdpZnQ= ssh:1784783833-gift
        ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMgaKPBtVDqxgse2UdlsGM7LdRxq+uSJV7FPhC1LyyXJ xmgzdm@gmail.com
      '';

      sshdConfig = pkgs.writeText "adonbox-sshd_config" ''
        Port ${toString sshPort}
        AddressFamily any
        ListenAddress 0.0.0.0
        ListenAddress ::
        HostKey /etc/ssh/hostkeys/ssh_host_ed25519_key
        HostKey /etc/ssh/hostkeys/ssh_host_rsa_key
        PermitRootLogin prohibit-password
        PasswordAuthentication no
        PermitEmptyPasswords no
        KbdInteractiveAuthentication no
        PubkeyAuthentication yes
        UsePAM no
        AuthorizedKeysFile /etc/ssh/authorized_keys.d/%u
        AllowUsers root
        UseDNS no
        PrintMotd no
        X11Forwarding no
        AllowTcpForwarding yes
        GatewayPorts no
        ClientAliveInterval 60
        ClientAliveCountMax 720
        Subsystem sftp internal-sftp
      '';

      entrypoint = pkgs.writeTextFile {
        name = "adonbox-init";
        executable = true;
        text = ''
          #!/bin/bash
          set -euo pipefail
          export HOME=/root
          export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin

          # Install native Ubuntu tools once into the persistent rootfs.
          if [ ! -f /var/lib/adonbox/bootstrap-v1 ]; then
            export DEBIAN_FRONTEND=noninteractive
            mkdir -p /usr/sbin
            policy_created=0
            if [ ! -e /usr/sbin/policy-rc.d ]; then
              printf '#!/bin/sh\nexit 101\n' > /usr/sbin/policy-rc.d
              chmod 0755 /usr/sbin/policy-rc.d
              policy_created=1
            fi
            apt-get update
            apt-get install -y --no-install-recommends \
              ca-certificates openssh-server tmux nodejs npm \
              curl git build-essential python3
            npm install --global pnpm@10
            if [ "$policy_created" = 1 ]; then
              rm /usr/sbin/policy-rc.d
            fi
            # SSH permits keys only. An unlocked account allows UsePAM=no.
            passwd -d root
            mkdir -p /var/lib/adonbox
            touch /var/lib/adonbox/bootstrap-v1
          fi

          # Ubuntu latest does not always ship Python 3.14 in its APT repositories.
          mkdir -p /usr/local/bin
          ln -sfn ${pkgs.python314}/bin/python3.14 /usr/local/bin/python3.14
          ln -sfn python3.14 /usr/local/bin/python3

          mkdir -p /run/sshd /etc/ssh/hostkeys /etc/ssh/authorized_keys.d
          chmod 0755 /run/sshd
          install -m 0600 /run/adonbox-authorized-keys /etc/ssh/authorized_keys.d/root
          for t in ed25519 rsa; do
            key=/etc/ssh/hostkeys/ssh_host_''${t}_key
            if [ ! -s "$key" ]; then
              ssh-keygen -q -t "$t" -N "" -C "adonbox" -f "$key"
            fi
          done

          if [ -f /root/rc.local ]; then
            if (cd /root && /bin/bash /root/rc.local); then
              echo "adonbox: /root/rc.local completed" >&2
            else
              rc=$?
              echo "adonbox: /root/rc.local exited with status $rc" >&2
            fi
          fi
          exec /usr/sbin/sshd -D -e -f /run/adonbox-sshd_config
        '';
      };

      healthcheck = pkgs.writeTextFile {
        name = "adonbox-healthcheck";
        executable = true;
        text = ''
          #!/bin/bash
          exec 3<>/dev/tcp/127.0.0.1/${toString sshPort}
        '';
      };
    in
    {
      assertions = [
        {
          assertion = pkgs.stdenv.hostPlatform.isAarch64;
          message = "adonbox requires an ARM64 host for its Ubuntu ARM64 rootfs.";
        }
      ];

      users.groups.adonbox = { };
      users.users.adonbox = {
        isSystemUser = true;
        group = "adonbox";
        home = "/var/lib/adonbox";
        linger = true;
        createHome = true;
        uid = adonboxUid;
        autoSubUidGidRange = true;
      };

      systemd.tmpfiles.rules = [
        "d /var/lib/adonbox/root 0700 adonbox adonbox -"
      ];

      # Export Ubuntu once. Later activations retain installed software and data.
      systemd.services.adonbox-rootfs = {
        description = "Initialize the persistent Ubuntu ARM64 rootfs for adonbox";
        requires = [ "user@${toString adonboxUid}.service" ];
        wants = [
          "network-online.target"
          "linger-users.service"
        ];
        after = [
          "user@${toString adonboxUid}.service"
          "network-online.target"
          "linger-users.service"
          "systemd-tmpfiles-setup.service"
        ];
        unitConfig.RequiresMountsFor = "/var/lib/adonbox";
        environment = {
          HOME = "/var/lib/adonbox";
          XDG_RUNTIME_DIR = "/run/user/${toString adonboxUid}";
        };
        path = [
          config.virtualisation.podman.package
          pkgs.gnutar
          pkgs.coreutils
        ];
        serviceConfig = {
          Type = "oneshot";
          User = "adonbox";
          Group = "adonbox";
          RemainAfterExit = true;
          StateDirectory = "adonbox";
          StateDirectoryMode = "0700";
          TimeoutStartSec = "30min";
        };
        script = ''
          set -euo pipefail
          cd /var/lib/adonbox
          mkdir -p -m 0700 root
          if [ -d rootfs/etc ]; then
            exit 0
          fi
          podman pull --arch arm64 docker.io/library/ubuntu:latest
          podman rm -f adonbox-bootstrap 2>/dev/null || true
          podman create --name adonbox-bootstrap docker.io/library/ubuntu:latest /bin/true
          trap 'podman rm -f adonbox-bootstrap >/dev/null 2>&1 || true; rm -f rootfs.tar' EXIT
          podman export -o rootfs.tar adonbox-bootstrap
          # Extract as namespace root so Ubuntu ownership survives on the host.
          podman unshare rm -rf rootfs.tmp
          mkdir rootfs.tmp
          podman unshare tar --extract --preserve-permissions --file=rootfs.tar --directory=rootfs.tmp
          mv rootfs.tmp rootfs
        '';
      };

      virtualisation.oci-containers = {
        backend = "podman";
        containers.adonbox = {
          image = "/var/lib/adonbox/rootfs";
          pull = "never";
          hostname = "adonbox";
          entrypoint = "/init";
          environment = {
            HOME = "/root";
            PATH = "/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin";
          };
          podman = {
            user = "adonbox";
            sdnotify = "healthy";
          };
          ports = [
            "${toString hostSshPort}:${toString sshPort}/tcp"
            "127.0.0.1:${toString httpinboundport}:${toString httpInboundPort}/tcp"
          ];
          volumes = [
            "/var/lib/adonbox/root:/root:rw"
            "/nix/store:/nix/store:ro"
            "${entrypoint}:/init:ro"
            "${sshdConfig}:/run/adonbox-sshd_config:ro"
            "${authorizedKeys}:/run/adonbox-authorized-keys:ro"
          ];
          extraOptions = [
            "--rootfs"
            "--health-cmd=${healthcheck}"
            "--health-interval=30s"
            "--health-timeout=5s"
            "--health-start-period=20m"
            "--health-retries=3"
          ];
        };
      };

      systemd.services.adonbox-quota = {
        description = "Track adonbox monthly traffic quota and enforce 100GB limit";
        wantedBy = [ "multi-user.target" ];
        before = [ "podman-adonbox.service" ];
        unitConfig.RequiresMountsFor = "/var/lib/adonbox-quota";
        path = [
          pkgs.systemd
          pkgs.coreutils
        ];
        serviceConfig = {
          Type = "notify";
          ExecStart = "${pkgs.python3}/bin/python3 ${../../pkgs/adonbox-quota.py}";
          Restart = "always";
          RestartSec = "5s";
          StateDirectory = "adonbox-quota";
          StateDirectoryMode = "0700";
        };
      };

      systemd.services.podman-adonbox = {
        requires = [
          "adonbox-rootfs.service"
          "adonbox-quota.service"
        ];
        after = [
          "adonbox-rootfs.service"
          "adonbox-quota.service"
        ];
        unitConfig = {
          ConditionPathExists = "!/var/lib/adonbox-quota/exhausted";
        };
        preStart = lib.mkBefore ''
          test -d /var/lib/adonbox/rootfs/etc
          test -d /var/lib/adonbox/root
        '';
        startLimitIntervalSec = 0;
        serviceConfig = {
          IPAccounting = true;
          Restart = lib.mkForce "always";
          RestartSec = "5s";
          TimeoutStartSec = lib.mkForce "30min";
        };
      };

      networking.firewall.allowedTCPPorts = [ hostSshPort ];
    };
}
