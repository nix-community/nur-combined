{
  lib,
  pkgs,
}:

pkgs.testers.runNixOSTest {
  name = "ztnet";

  nodes.machine = _: {
    imports = [
      ../modules/services/web-apps/ztnet.nix
    ];

    services.ztnet = {
      enable = true;
      package = pkgs.ztnet;
      zerotier.manageState = true;
      settings = {
        NEXTAUTH_URL = "http://localhost:3000";
        NEXTAUTH_SECRET = "0123456789abcdef0123456789abcdef";
      };
    };
  };

  testScript = ''
    machine.wait_for_unit("zerotierone.service")
    machine.wait_for_file("/var/lib/zerotier-one/authtoken.secret")
    # Connecting to the socket starts the service, so do not probe the port first.
    machine.wait_for_unit("ztnet.socket")
    machine.fail("systemctl is-active --quiet ztnet.service")
    machine.succeed("curl -fs http://localhost:3000/auth/login")
    machine.wait_for_unit("ztnet.service")
    machine.wait_for_unit("postgresql.service")

    with subtest("manageState allows ZeroTier state changes"):
        run = "systemd-run --wait --pipe --uid=ztnet -p PrivateUsers=no -p AmbientCapabilities='CAP_CHOWN CAP_DAC_OVERRIDE CAP_FOWNER'"
        machine.succeed(f"{run} touch /var/lib/zerotier-one/ztnet-test")
        machine.succeed(f"{run} systemctl restart zerotierone.service")
        machine.wait_for_unit("zerotierone.service")
        # Stopping ZeroTier must not take ZTNET down with it.
        machine.succeed("systemctl stop zerotierone.service")
        machine.succeed("systemctl is-active --quiet ztnet.service")
  '';

  meta.maintainers = with lib.maintainers; [ moraxyc ];
}
