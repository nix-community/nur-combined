{
  name = "mxc-bwrap";
  meta.timeout = 1800;

  imports = [ ./mxc-internet.nix ];

  nodes.machine =
    { mxc, pkgs, ... }:
    {
      virtualisation.memorySize = 2048;
      networking.firewall.enable = false;
      # The inbound default-deny test installs conntrack rules.
      boot.kernelModules = [ "nf_conntrack" ];

      # run_bwrap_filesystem_test.sh chowns to "$USER:$USER".
      users.users.alice = {
        isNormalUser = true;
        group = "alice";
        extraGroups = [ "wheel" ];
      };
      users.groups.alice = { };
      security.sudo.wheelNeedsPassword = false;

      environment.systemPackages = with pkgs; [
        mxc
        bubblewrap
        slirp4netns
        util-linux
        iptables
        iproute2
        python3
        procps
        wget
      ];
      environment.etc."mxc-src".source = mxc.src;
      # The unwrapped executable: run_bwrap_version_gate_test.sh controls which
      # bwrap is on PATH, which the wrapper's PATH prefix would override.
      environment.etc."mxc-libexec".source = "${mxc}/libexec/mxc";
      # run_bwrap_environment_test.sh hardcodes upstream's DEFAULT_PATH, which
      # the package replaces with one that works on NixOS.
      environment.etc."mxc-default-path".text = mxc.defaultSandboxPath;

      # Several configs run /bin/bash and /bin/sleep by absolute path, and the
      # firewall configs set an FHS-only PATH for their probes.
      systemd.tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
        "L+ /bin/sleep - - - - ${pkgs.coreutils}/bin/sleep"
      ]
      ++ map (exe: "L+ /usr/bin/${baseNameOf exe} - - - - ${exe}") [
        "${pkgs.coreutils}/bin/cut"
        "${pkgs.coreutils}/bin/readlink"
        "${pkgs.coreutils}/bin/timeout"
        "${pkgs.gnugrep}/bin/grep"
        "${pkgs.iptables}/bin/iptables"
      ];
    };

  testScript = ''
    start_all()
    internet.wait_for_unit("anchors.service")
    machine.wait_for_unit("multi-user.target")

    # The scripts expect a checkout with the binaries under src/target/release.
    machine.succeed(
      "cp -rH --no-preserve=mode /etc/mxc-src /home/alice/mxc",
      "mkdir -p /home/alice/mxc/src/target/release",
      "ln -s /etc/mxc-libexec/lxc-exec $(command -v unix-test-proxy) /home/alice/mxc/src/target/release/",
      "sed -i \"s|^DEFAULT_PATH=.*|DEFAULT_PATH='$(cat /etc/mxc-default-path)'|\" /home/alice/mxc/tests/scripts/run_bwrap_environment_test.sh",
      "chown -R alice:alice /home/alice/mxc",
    )
    machine.succeed("timeout 5 bash -c 'exec 3<>/dev/tcp/1.1.1.1/443'")

    with subtest("inbound default-deny (root)"):
      # 77 means a prerequisite was missing; that must not pass.
      machine.succeed("bash /home/alice/mxc/tests/scripts/run_bwrap_inbound_deny_test.sh >&2")

    with subtest("unprivileged suite"):
      # Strict mode fails on a skipped prerequisite instead of passing.
      machine.succeed(
        "su -l alice -c 'MXC_BWRAP_TESTS_REQUIRE_EXECUTION=1 bash mxc/tests/scripts/run_bwrap_all_tests.sh' >&2"
      )
  '';
}
