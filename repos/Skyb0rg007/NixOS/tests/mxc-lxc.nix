{
  name = "mxc-lxc";
  meta.timeout = 3600;

  imports = [ ./mxc-internet.nix ];

  nodes.machine =
    {
      mxc,
      pkgs,
      lib,
      ...
    }:
    let
      # The LXC backend creates every container with `lxc-create -t download`,
      # by default `-- -d alpine -r 3.23`. The test has no network, so seed the
      # download template's cache, which it uses as-is when no expiry file is
      # present. The minirootfs has no openrc, so boot it with busybox init and
      # bring the network up with busybox ifup/udhcpc on lxcbr0.
      mkDownloadCache =
        {
          name,
          extraFiles ? "",
          extraConfig ? "",
        }:
        pkgs.runCommand "lxc-download-${name}"
          {
            src = pkgs.fetchurl {
              url = "https://dl-cdn.alpinelinux.org/alpine/v3.23/releases/x86_64/alpine-minirootfs-3.23.6-x86_64.tar.gz";
              hash = "sha256-b8DjY5ocAfFWlw12Jqq5C8kGlxFwadvDmtiAuE76MZo=";
            };
            nativeBuildInputs = [ pkgs.xz ];
          }
          ''
            mkdir -p overlay/etc/network $out
            cat > overlay/etc/inittab <<EOF
            ::sysinit:/sbin/ifup -a
            ::shutdown:/sbin/ifdown -a
            EOF
            cat > overlay/etc/network/interfaces <<EOF
            auto lo
            iface lo inet loopback

            auto eth0
            iface eth0 inet dhcp
            EOF
            ${extraFiles}

            # Appended entries replace the originals on extraction, and the
            # rest of the archive keeps its ownership.
            gzip -dc $src > rootfs.tar
            (cd overlay && find . ! -type d) | sort > files
            tar --append -f rootfs.tar -C overlay --owner=0 --group=0 --numeric-owner -T files
            xz -T0 < rootfs.tar > $out/rootfs.tar.xz

            cat > $out/config <<EOF
            lxc.include = LXC_TEMPLATE_CONFIG/common.conf
            lxc.arch = x86_64
            lxc.signal.halt = SIGUSR1
            ${extraConfig}
            EOF
          '';
      alpineCache = mkDownloadCache { name = "alpine-3.23"; };
      # The GA egress test's io_uring case asks for Ubuntu Noble because Alpine
      # ships no python3. Stand in the same Alpine rootfs with the host's
      # python3 reachable through a read-only bind of /nix/store.
      noblePythonCache = mkDownloadCache {
        name = "ubuntu-noble-python3";
        extraFiles = ''
          mkdir -p overlay/usr/bin
          ln -s ${lib.getExe pkgs.python3} overlay/usr/bin/python3
        '';
        extraConfig = "lxc.mount.entry = /nix/store nix/store none ro,bind,create=dir 0 0";
      };
    in
    {
      virtualisation.memorySize = 2048;
      networking.firewall.enable = false;
      boot.kernelModules = [ "nf_conntrack" ];

      virtualisation.lxc = {
        enable = true;
        # Also brings up lxc-net, which provides lxcbr0 and its dnsmasq.
        unprivilegedContainers = true;
        defaultConfig = ''
          lxc.net.0.type = veth
          lxc.net.0.link = lxcbr0
          lxc.net.0.flags = up
          lxc.net.0.hwaddr = 00:16:3e:xx:xx:xx
        '';
      };
      systemd.tmpfiles.rules = [
        "L+ /var/cache/lxc/download/alpine/3.23/amd64/default - - - - ${alpineCache}"
        "L+ /var/cache/lxc/download/ubuntu/noble/amd64/default - - - - ${noblePythonCache}"
      ];

      environment.systemPackages = with pkgs; [
        mxc
        util-linux
        iptables
        iproute2
        python3
        procps
        wget
        xz
      ];
      environment.etc."mxc-src".source = mxc.src;
    };

  testScript = ''
    start_all()
    internet.wait_for_unit("anchors.service")
    machine.wait_for_unit("lxc-net.service")
    machine.wait_until_succeeds("ip -4 addr show lxcbr0 | grep -q inet")

    # The scripts expect a checkout with the binaries under src/target/release.
    machine.succeed(
      "cp -rH --no-preserve=mode /etc/mxc-src /root/mxc",
      "mkdir -p /root/mxc/src/target/release",
      "ln -s $(command -v lxc-exec) $(command -v unix-test-proxy) /root/mxc/src/target/release/",
    )
    machine.succeed("timeout 5 bash -c 'exec 3<>/dev/tcp/140.82.114.6/443'")

    # Strict mode fails on a skipped prerequisite instead of passing.
    machine.succeed("MXC_LXC_TESTS_REQUIRE_EXECUTION=1 bash /root/mxc/tests/scripts/run_lxc_all_tests.sh >&2")
  '';
}
