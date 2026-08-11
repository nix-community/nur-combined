{
  name = "credentialsd";
  meta.timeout = 120;

  nodes.machine =
    { config, lib, ... }:
    {
      services.credentialsd = {
        enable = true;
        browserIntegration.chrome.allowedOrigins = [
          "chrome-extension://abcdefghijklmnopabcdefghijklmnop/"
        ];
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
          "xyz.iinuwa.credentialsd.FlowControl.service",
          "xyz.iinuwa.credentialsd.UiControl.service",
      ]:
          machine.succeed(f"test -e /etc/systemd/user/{unit}")
          machine.succeed(f"test -e /etc/systemd/user/default.target.wants/{unit}")

    with subtest("D-Bus activation files are installed"):
      for service in [
          "xyz.iinuwa.credentialsd.Credentials.service",
          "xyz.iinuwa.credentialsd.FlowControl.service",
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
  '';
}
