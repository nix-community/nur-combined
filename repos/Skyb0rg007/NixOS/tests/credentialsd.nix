{
  name = "credentialsd";
  meta.timeout = 300;

  nodes.machine =
    { config, lib, ... }:
    {
      services.credentialsd = {
        enable = true;
        browserIntegration.chrome.allowedOrigins = [
          "chrome-extension://abcdefghijklmnopabcdefghijklmnop/"
        ];
      };

      users.users.alice = {
        isNormalUser = true;
        linger = true;
      };

      # The portal unit requires graphical-session.target, which refuses a
      # manual start and is normally bound to by the desktop session.
      systemd.user.targets.test-session = {
        wantedBy = [ "default.target" ];
        bindsTo = [ "graphical-session.target" ];
      };

      assertions = [
        {
          assertion = lib.elem config.services.credentialsd.package config.programs.firefox.nativeMessagingHosts.packages;
          message = "credentialsd should register its Firefox native messaging host package";
        }
      ];
    };

  testScript = ''
    machine.start()
    machine.wait_for_unit("multi-user.target")

    with subtest("systemd user units are installed and enabled"):
      for unit in [
          "xyz.iinuwa.credentialsd.Credentials.service",
          "xyz.iinuwa.credentialsd.UiControl.service",
      ]:
          machine.succeed(f"test -e /etc/systemd/user/{unit}")
          machine.succeed(f"test -e /etc/systemd/user/default.target.wants/{unit}")

    with subtest("D-Bus activation files are installed"):
      for service in [
          "xyz.iinuwa.credentialsd.Credentials.service",
          "xyz.iinuwa.credentialsd.UiControl.service",
      ]:
          machine.succeed(f"test -e /run/current-system/sw/share/dbus-1/services/{service}")

    with subtest("Chrome and Chromium native messaging hosts are configured"):
      for manifest in [
          "/etc/chromium/native-messaging-hosts/xyz.iinuwa.credentialsd_helper.json",
          "/etc/opt/chrome/native-messaging-hosts/xyz.iinuwa.credentialsd_helper.json",
      ]:
          machine.succeed(f"test -e {manifest}")
          machine.succeed(f"grep -q 'xyz.iinuwa.credentialsd_helper' {manifest}")
          machine.succeed(f"grep -q 'chrome-extension://abcdefghijklmnopabcdefghijklmnop/' {manifest}")
          machine.succeed(f"grep -q '/bin/credentialsd-firefox-helper' {manifest}")

    def alice(command):
        return (
            "su - alice -c "
            f"'XDG_RUNTIME_DIR=/run/user/1000 {command}'"
        )

    with subtest("the portal exposes the Credential interface in a user session"):
      machine.wait_for_unit("user@1000.service")
      machine.wait_until_succeeds(
          alice(
              "busctl --user introspect org.freedesktop.portal.Desktop "
              "/org/freedesktop/portal/desktop "
              "| grep -F org.freedesktop.portal.experimental.Credential"
          ),
          timeout=60,
      )

    with subtest("the portal keeps the session PATH"):
      pid = machine.succeed(
          alice("systemctl --user show -P MainPID xdg-desktop-portal.service")
      ).strip()
      machine.succeed(
          f"xargs -0 -n1 < /proc/{pid}/environ | grep -E '^PATH=.*/run/current-system/sw/bin'"
      )
  '';
}
